import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks/lifecycle_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/lifecycle_repository_provider.dart';
import '../domain/entities/lifecycle_event.dart';
import 'reminder_reconciliation_callbacks.dart';
import 'diagnostic_logger_provider.dart';

/// Composition root for task completion, reopening, and lifecycle history.
final taskLifecycleActionsProvider = FutureProvider<TaskLifecycleActions>((
  ref,
) async {
  final repository = await ref.watch(lifecycleRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  final logger = ref.watch(diagnosticLoggerProvider);
  return TaskLifecycleActions(
    repository,
    profile.id,
    onChanged: () => reconcileRemindersAfterChange(ref, profile.id),
    logger: logger,
  );
});

final watchTaskLifecycleHistoryUseCaseProvider =
    FutureProvider<WatchTaskLifecycleHistory>((ref) async {
      final repository = await ref.watch(lifecycleRepositoryProvider.future);
      return WatchTaskLifecycleHistory(repository);
    });

final taskLifecycleHistoryProvider =
    StreamProvider.family<List<LifecycleEvent>, String>((ref, taskId) async* {
      final watchHistory = await ref.watch(
        watchTaskLifecycleHistoryUseCaseProvider.future,
      );
      yield* watchHistory(taskId);
    });
