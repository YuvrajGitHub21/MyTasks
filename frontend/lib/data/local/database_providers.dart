import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'local_profile_store.dart';

/// Opens the encrypted database once for the current ProviderScope.
final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final database = await AppDatabase.openEncrypted();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

/// Resolves the stable guest profile used to partition local task data.
final activeProfileProvider = FutureProvider<ProfileRecord>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return LocalProfileStore(database).getOrCreateGuestProfile();
});
