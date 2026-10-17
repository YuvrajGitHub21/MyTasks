import '../../domain/entities/lifecycle_event.dart';

/// Records task completion changes and exposes their append-only history.
abstract interface class LifecycleRepository {
  /// Completes an open task and records the event atomically.
  /// Returns false when [taskId] is not in the active profile.
  Future<bool> completeTask(String taskId, DateTime occurredAt);

  /// Reopens a completed task and records the event atomically.
  /// Returns false when [taskId] is not in the active profile.
  Future<bool> reopenTask(String taskId, DateTime occurredAt);

  /// Watches lifecycle history for a task visible to the active profile.
  Stream<List<LifecycleEvent>> watchEventsForTask(String taskId);
}
