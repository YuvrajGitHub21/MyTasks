import 'package:drift/drift.dart';

import '../../domain/entities/lifecycle_event.dart';
import '../../domain/repositories/lifecycle_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/rules/task_rules.dart';
import 'app_database.dart';

/// Drift implementation for atomic, profile-scoped lifecycle transitions.
final class DriftLifecycleRepository implements LifecycleRepository {
  DriftLifecycleRepository(this._database, this._profileId);

  final AppDatabase _database;
  final String _profileId;

  @override
  Future<bool> recordTransition(LifecycleEvent event) async {
    if (event.profileId != _profileId) {
      throw StateError(
        'A lifecycle event cannot be saved under a different profile.',
      );
    }
    if (event.id.trim().isEmpty || event.taskId.trim().isEmpty) {
      throw ArgumentError('Lifecycle event ID and task ID cannot be empty.');
    }
    final instant = event.occurredAt.toUtc();

    return _database.transaction(() async {
      final task =
          await (_database.select(_database.localTasks)..where(
                (row) =>
                    row.id.equals(event.taskId) &
                    row.profileId.equals(_profileId),
              ))
              .getSingleOrNull();
      if (task == null) return false;

      final currentStatus = _statusFromStorage(task.status);
      final errors = TaskRules.validateLifecycleTransition(
        currentStatus: currentStatus,
        event: event.type,
      );
      if (errors.isNotEmpty) {
        throw StateError(errors['status']!);
      }

      final nextStatus = switch (event.type) {
        LifecycleEventType.completed => TaskStatus.completed,
        LifecycleEventType.reopened => TaskStatus.open,
      };
      final updatedRows =
          await (_database.update(_database.localTasks)..where(
                (row) =>
                    row.id.equals(event.taskId) &
                    row.profileId.equals(_profileId),
              ))
              .write(
                LocalTasksCompanion(
                  status: Value(_statusToStorage(nextStatus)),
                  completedAtUtc: Value(
                    nextStatus == TaskStatus.completed ? instant : null,
                  ),
                  updatedAtUtc: Value(instant),
                ),
              );
      if (updatedRows != 1) {
        throw StateError(
          'The task changed before its lifecycle event was saved.',
        );
      }

      await _database
          .into(_database.localLifecycleEvents)
          .insert(
            LocalLifecycleEventsCompanion(
              id: Value(event.id),
              profileId: Value(_profileId),
              taskId: Value(event.taskId),
              eventType: Value(_eventToStorage(event.type)),
              occurredAtUtc: Value(instant),
            ),
          );
      return true;
    });
  }

  @override
  Stream<List<LifecycleEvent>> watchEventsForTask(String taskId) {
    return (_database.select(_database.localLifecycleEvents)
          ..where(
            (event) =>
                event.profileId.equals(_profileId) &
                event.taskId.equals(taskId),
          )
          ..orderBy([
            (event) => OrderingTerm.desc(event.occurredAtUtc),
            (event) => OrderingTerm.desc(event.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  TaskStatus _statusFromStorage(String status) => switch (status) {
    'OPEN' => TaskStatus.open,
    'COMPLETED' => TaskStatus.completed,
    _ => throw StateError('The database contains an unknown task status.'),
  };

  String _statusToStorage(TaskStatus status) => switch (status) {
    TaskStatus.open => 'OPEN',
    TaskStatus.completed => 'COMPLETED',
  };

  String _eventToStorage(LifecycleEventType event) => switch (event) {
    LifecycleEventType.completed => 'COMPLETED',
    LifecycleEventType.reopened => 'REOPENED',
  };

  LifecycleEvent _toDomain(LifecycleEventRecord row) => LifecycleEvent(
    id: row.id,
    profileId: row.profileId,
    taskId: row.taskId,
    type: switch (row.eventType) {
      'COMPLETED' => LifecycleEventType.completed,
      'REOPENED' => LifecycleEventType.reopened,
      _ => throw StateError(
        'The database contains an unknown lifecycle event.',
      ),
    },
    occurredAt: row.occurredAtUtc.toUtc(),
  );
}
