import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';
import 'drift_lifecycle_repository.dart';
import '../../domain/repositories/lifecycle_repository.dart';

/// Builds a lifecycle repository scoped to the current guest profile.
final lifecycleRepositoryProvider = FutureProvider<LifecycleRepository>((
  ref,
) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return DriftLifecycleRepository(database, profile.id);
});
