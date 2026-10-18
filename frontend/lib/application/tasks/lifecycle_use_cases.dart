import 'package:uuid/uuid.dart';

import '../../domain/entities/lifecycle_event.dart';
import '../../domain/repositories/lifecycle_repository.dart';
import '../../domain/services/diagnostic_logger.dart';

/// Application actions that create stable lifecycle events before persistence.
final class TaskLifecycleActions {
  TaskLifecycleActions(
    this._lifecycle,
    this._profileId, {
    DateTime Function()? clock,
    Future<void> Function()? onChanged,
    this._logger = const NoopDiagnosticLogger(),
  }) : _clock = clock ?? DateTime.now,
       _onChanged = onChanged;

  static const _uuid = Uuid();

  final LifecycleRepository _lifecycle;
  final String _profileId;
  final DateTime Function() _clock;
  final Future<void> Function()? _onChanged;
  final DiagnosticLogger _logger;

  Future<bool> completeTask(String taskId) =>
      _record(taskId, LifecycleEventType.completed);

  Future<bool> reopenTask(String taskId) =>
      _record(taskId, LifecycleEventType.reopened);

  Future<bool> _record(String taskId, LifecycleEventType type) =>
      runDiagnosticOperation(
        logger: _logger,
        feature: 'tasks',
        eventName: type == LifecycleEventType.completed
            ? 'task.complete'
            : 'task.reopen',
        action: () async {
          final event = LifecycleEvent(
            id: _uuid.v4(),
            taskId: taskId,
            profileId: _profileId,
            type: type,
            occurredAt: _clock().toUtc(),
          );
          final changed = await _lifecycle.recordTransition(event);
          if (changed) await _onChanged?.call();
          return changed;
        },
      );
}

/// Application query for a task's append-only completion/reopening history.
final class WatchTaskLifecycleHistory {
  const WatchTaskLifecycleHistory(this._lifecycle);

  final LifecycleRepository _lifecycle;

  Stream<List<LifecycleEvent>> call(String taskId) =>
      _lifecycle.watchEventsForTask(taskId);
}
