import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'diagnostic_log_key_store.dart';
import 'diagnostic_log_record.dart';

/// Separate encrypted SQLite store for diagnostics; never uses the task DB.
/// SQLite3MultipleCiphers encrypts database pages with ChaCha20-Poly1305.
final class EncryptedDiagnosticLogStore {
  EncryptedDiagnosticLogStore({
    DiagnosticLogKeyStore? keyStore,
    Future<Directory> Function()? supportDirectory,
    this._keyLoader,
  }) : _keyStore = keyStore ?? DiagnosticLogKeyStore(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  static const maxDatabaseBytes = 2 * 1024 * 1024;
  static const _maxPages = maxDatabaseBytes ~/ 4096;
  static const _retention = Duration(days: 7);
  static const _fileName = 'mytasks-diagnostics.sqlite';

  final DiagnosticLogKeyStore _keyStore;
  final Future<Directory> Function() _supportDirectory;
  final Future<String> Function(bool logDatabaseExists)? _keyLoader;
  sqlite.Database? _database;
  File? _databaseFile;

  Future<void> initialize() async {
    if (_database != null) return;
    final directory = await _supportDirectory();
    await directory.create(recursive: true);
    final file = File(path.join(directory.path, _fileName));
    final exists = await file.exists();
    final key = _keyLoader == null
        ? await _keyStore.loadOrCreate(logDatabaseExists: exists)
        : await _keyLoader(exists);
    final db = sqlite.sqlite3.open(file.path);
    try {
      final cipher = db.select('PRAGMA cipher;');
      if (cipher.isEmpty || cipher.first.values.first == null) {
        throw StateError(
          'SQLite3MultipleCiphers is unavailable; refusing to store '
          'diagnostics without encryption.',
        );
      }
      db.execute("PRAGMA cipher = 'chacha20';");
      db.execute("PRAGMA key = 'raw:$key';");
      // Force key validation immediately. A lost/wrong key must not create a
      // fresh empty database over the existing diagnostic records.
      db.select('SELECT count(*) FROM sqlite_master;');
      db.execute('PRAGMA journal_mode = DELETE;');
      db.execute('PRAGMA synchronous = FULL;');
      db.execute('PRAGMA secure_delete = ON;');
      if (!exists) {
        db.execute('PRAGMA page_size = 4096;');
        db.execute('PRAGMA auto_vacuum = FULL;');
      }
      db.execute('''
          CREATE TABLE IF NOT EXISTS diagnostic_entries (
            event_id TEXT PRIMARY KEY NOT NULL,
            timestamp_utc TEXT NOT NULL,
            severity TEXT NOT NULL CHECK (severity IN
              ('debug', 'info', 'warning', 'error', 'fatal')),
            payload_json TEXT NOT NULL
          )
        ''');
      db.execute('''
          CREATE INDEX IF NOT EXISTS diagnostic_entries_time_idx
          ON diagnostic_entries (timestamp_utc)
        ''');
      db.execute('''
          CREATE INDEX IF NOT EXISTS diagnostic_entries_severity_time_idx
          ON diagnostic_entries (severity, timestamp_utc)
        ''');
      db.execute('PRAGMA max_page_count = $_maxPages;');
      _database = db;
      _databaseFile = file;
      _pruneExpired(DateTime.now().toUtc());
    } catch (_) {
      db.close();
      rethrow;
    }
  }

  Future<void> append(DiagnosticLogRecord record) async {
    final db = _requiredDatabase;
    _pruneExpired(DateTime.now().toUtc());
    final payload = record.toJson();
    try {
      _insert(db, record, payload);
    } on sqlite.SqliteException {
      _makeRoom(db, incomingSeverity: record.severity);
      try {
        _insert(db, record, payload);
      } on sqlite.SqliteException {
        // Bounded storage is more important than retaining an unbounded error
        // storm. The caller's operation remains successful either way.
      }
    }
  }

  Future<List<String>> readRecent({Duration age = _retention}) async {
    final cutoff = DateTime.now().toUtc().subtract(age).toIso8601String();
    return _requiredDatabase
        .select(
          'SELECT payload_json FROM diagnostic_entries '
          'WHERE timestamp_utc >= ? ORDER BY timestamp_utc DESC',
          [cutoff],
        )
        .map((row) => row['payload_json'] as String)
        .toList(growable: false);
  }

  Future<List<String>> readRecentErrors({Duration age = _retention}) async {
    final cutoff = DateTime.now().toUtc().subtract(age).toIso8601String();
    return _requiredDatabase
        .select(
          "SELECT payload_json FROM diagnostic_entries "
          "WHERE severity IN ('error', 'fatal') AND timestamp_utc >= ? "
          'ORDER BY timestamp_utc DESC',
          [cutoff],
        )
        .map((row) => row['payload_json'] as String)
        .toList(growable: false);
  }

  Future<void> close() async {
    _database?.close();
    _database = null;
    _databaseFile = null;
  }

  int get databaseSizeBytes => _databaseFile?.lengthSync() ?? 0;

  sqlite.Database get _requiredDatabase =>
      _database ?? (throw StateError('Diagnostic log store is not open.'));

  void _insert(sqlite.Database db, DiagnosticLogRecord record, String payload) {
    db.execute(
      'INSERT OR REPLACE INTO diagnostic_entries '
      '(event_id, timestamp_utc, severity, payload_json) VALUES (?, ?, ?, ?)',
      [
        record.eventId,
        record.occurredAtUtc.toUtc().toIso8601String(),
        record.severity.name,
        payload,
      ],
    );
  }

  void _pruneExpired(DateTime nowUtc) {
    _requiredDatabase.execute(
      'DELETE FROM diagnostic_entries WHERE timestamp_utc < ?',
      [nowUtc.subtract(_retention).toIso8601String()],
    );
  }

  void _makeRoom(
    sqlite.Database db, {
    required DiagnosticSeverity incomingSeverity,
  }) {
    // Preserve the newest errors as long as possible: discard oldest low
    // severity activity first, then warnings, and errors only as a last resort.
    const evictionOrder = ['debug', 'info', 'warning', 'error', 'fatal'];
    while (_pageCount(db) >= _maxPages) {
      var removedRecord = false;
      for (final severity in evictionOrder) {
        if (severity == 'error' &&
            incomingSeverity != DiagnosticSeverity.error &&
            incomingSeverity != DiagnosticSeverity.fatal) {
          continue;
        }
        if (severity == 'fatal' &&
            incomingSeverity != DiagnosticSeverity.fatal) {
          continue;
        }
        final oldest = db.select(
          'SELECT event_id FROM diagnostic_entries WHERE severity = ? '
          'ORDER BY timestamp_utc ASC LIMIT 1',
          [severity],
        );
        if (oldest.isNotEmpty) {
          db.execute('DELETE FROM diagnostic_entries WHERE event_id = ?', [
            oldest.first['event_id'],
          ]);
          removedRecord = true;
          break;
        }
      }
      if (!removedRecord) return;
    }
  }

  int _pageCount(sqlite.Database db) =>
      (db.select('PRAGMA page_count;').first.values.first as int);
}
