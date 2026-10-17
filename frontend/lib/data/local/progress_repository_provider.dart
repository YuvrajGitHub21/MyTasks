import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';
import 'drift_progress_repository.dart';
import 'progress_repository.dart';

/// Builds a progress repository scoped to the current guest profile.
final progressRepositoryProvider = FutureProvider<ProgressRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return DriftProgressRepository(database, profile.id);
});
