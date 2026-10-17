import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks/lifecycle_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/lifecycle_repository_provider.dart';

/// Composition root for task completion, reopening, and lifecycle history.
final taskLifecycleActionsProvider = FutureProvider<TaskLifecycleActions>((
  ref,
) async {
  final repository = await ref.watch(lifecycleRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return TaskLifecycleActions(repository, profile.id);
});

final watchTaskLifecycleHistoryUseCaseProvider =
    FutureProvider<WatchTaskLifecycleHistory>((ref) async {
      final repository = await ref.watch(lifecycleRepositoryProvider.future);
      return WatchTaskLifecycleHistory(repository);
    });
