import 'package:uuid/uuid.dart';

import '../../domain/entities/lifecycle_event.dart';
import '../../domain/repositories/lifecycle_repository.dart';

/// Application actions that create stable lifecycle events before persistence.
final class TaskLifecycleActions {
  TaskLifecycleActions(
    this._lifecycle,
    this._profileId, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const _uuid = Uuid();

  final LifecycleRepository _lifecycle;
  final String _profileId;
  final DateTime Function() _clock;

  Future<bool> completeTask(String taskId) =>
      _record(taskId, LifecycleEventType.completed);

  Future<bool> reopenTask(String taskId) =>
      _record(taskId, LifecycleEventType.reopened);

  Future<bool> _record(String taskId, LifecycleEventType type) {
    final event = LifecycleEvent(
      id: _uuid.v4(),
      taskId: taskId,
      profileId: _profileId,
      type: type,
      occurredAt: _clock().toUtc(),
    );
    return _lifecycle.recordTransition(event);
  }
}

/// Application query for a task's append-only completion/reopening history.
final class WatchTaskLifecycleHistory {
  const WatchTaskLifecycleHistory(this._lifecycle);

  final LifecycleRepository _lifecycle;

  Stream<List<LifecycleEvent>> call(String taskId) =>
      _lifecycle.watchEventsForTask(taskId);
}
