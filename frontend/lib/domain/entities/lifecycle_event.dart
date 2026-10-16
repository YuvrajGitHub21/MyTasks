/// An append-only event describing a task lifecycle transition.
enum LifecycleEventType { completed, reopened }

final class LifecycleEvent {
  const LifecycleEvent({
    required this.id,
    required this.taskId,
    required this.profileId,
    required this.type,
    required this.occurredAt,
  });

  final String id;
  final String taskId;
  final String profileId;
  final LifecycleEventType type;
  final DateTime occurredAt;
}
