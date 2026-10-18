import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'local_profile_store.dart';
import 'local_diagnostic_logger.dart';

/// Opens the encrypted database once for the current ProviderScope.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  try {
    final database = await AppDatabase.openEncrypted();
    ref.onDispose(() => unawaited(database.close()));
    return database;
  } catch (error, stackTrace) {
    LocalDiagnosticLogger.shared.failure(
      'database.open.failed',
      feature: 'database',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

/// Resolves the stable guest profile used to partition local task data.
final activeProfileProvider = FutureProvider<ProfileRecord>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return LocalProfileStore(database).getOrCreateGuestProfile();
});
