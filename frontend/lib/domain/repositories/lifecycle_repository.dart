import '../entities/lifecycle_event.dart';

/// Persistence port for atomic lifecycle transitions and their history.
abstract interface class LifecycleRepository {
  /// Applies the transition and appends [event] together in one transaction.
  /// Returns false when the event's task is absent from its profile.
  Future<bool> recordTransition(LifecycleEvent event);

  /// Watches lifecycle history for a task visible to the active profile.
  Stream<List<LifecycleEvent>> watchEventsForTask(String taskId);
}
