import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Reads or creates the random key used to encrypt the local task database.
///
/// The key is stored by the operating system's secure storage. It must never be
/// logged or embedded in source code.
final class DatabaseKeyStore {
  DatabaseKeyStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const _storageKey = 'mytasks.local_database_key.v1';
  static final _hexKeyPattern = RegExp(r'^[0-9a-f]{64}$');

  final FlutterSecureStorage _storage;

  /// Returns the existing 256-bit key, or creates one for a new database.
  ///
  /// If a database file already exists but secure storage has lost its key,
  /// this method fails instead of creating a new key that cannot decrypt it.
  Future<String> loadOrCreate({required bool databaseExists}) async {
    final storedKey = await _storage.read(key: _storageKey);
    if (storedKey != null) {
      if (!_hexKeyPattern.hasMatch(storedKey)) {
        throw StateError('The saved local database key is invalid.');
      }
      return storedKey;
    }

    if (databaseExists) {
      throw StateError(
        'The local database exists, but its encryption key is missing. '
        'The database was not opened or replaced.',
      );
    }

    final key = _generateKey();
    await _storage.write(key: _storageKey, value: key);
    return key;
  }

  String _generateKey() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256))
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
