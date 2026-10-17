import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'database_key_store.dart';

/// Creates the encrypted Drift connection used by the local database.
///
/// This is only a connection factory. Versioned tables, migrations, and
/// repository operations are added in later M2-C batches.
final class EncryptedDatabaseConnection {
  EncryptedDatabaseConnection({DatabaseKeyStore? keyStore})
    : _keyStore = keyStore ?? DatabaseKeyStore();

  final DatabaseKeyStore _keyStore;

  Future<DatabaseConnection> open() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final databasePath = path.join(supportDirectory.path, 'mytasks.sqlite');
    final databaseExists = await File(databasePath).exists();
    final key = await _keyStore.loadOrCreate(databaseExists: databaseExists);

    return driftDatabase(
      name: 'mytasks',
      native: DriftNativeOptions(
        databasePath: () async => databasePath,
        setup: (commonDatabase) {
          if (commonDatabase is! sqlite.Database) {
            throw StateError(
              'Encrypted SQLite is unavailable on this platform.',
            );
          }

          final cipherRows = commonDatabase.select('PRAGMA cipher;');
          if (cipherRows.isEmpty || cipherRows.first.values.first == null) {
            throw StateError(
              'SQLite3MultipleCiphers is unavailable; refusing to open an '
              'unencrypted local database.',
            );
          }

          // SQLite3MultipleCiphers selects the sqleet ChaCha20-Poly1305
          // scheme using the pragma name `chacha20`.
          commonDatabase.execute("PRAGMA cipher = 'chacha20';");
          commonDatabase.execute("PRAGMA key = 'raw:$key';");

          // Force SQLite to read an encrypted page now. A wrong key must fail
          // during connection setup, rather than later as an empty database.
          commonDatabase.select('SELECT count(*) FROM sqlite_master;');
        },
      ),
    );
  }
}
