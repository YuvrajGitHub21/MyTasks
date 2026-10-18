import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure-storage key for the diagnostics database, separate from task data.
final class DiagnosticLogKeyStore {
  DiagnosticLogKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const _storageKey = 'mytasks.diagnostic_log_key.v1';
  static final _hexKeyPattern = RegExp(r'^[0-9a-f]{64}$');
  final FlutterSecureStorage _storage;

  Future<String> loadOrCreate({required bool logDatabaseExists}) async {
    final stored = await _storage.read(key: _storageKey);
    if (stored != null) {
      if (!_hexKeyPattern.hasMatch(stored)) {
        throw StateError('The saved diagnostic log key is invalid.');
      }
      return stored;
    }
    if (logDatabaseExists) {
      throw StateError(
        'The diagnostic log database exists, but its key is missing. '
        'Existing logs were preserved.',
      );
    }
    final random = Random.secure();
    final key = List<int>.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _storageKey, value: key);
    return key;
  }
}
