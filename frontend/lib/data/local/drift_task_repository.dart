import 'package:drift/drift.dart';

import '../../domain/entities/task.dart';
import '../../domain/rules/task_rules.dart';
import 'app_database.dart';
import '../../domain/repositories/task_repository.dart';

/// Drift-backed task repository. Every operation includes the active profile.
final class DriftTaskRepository implements TaskRepository {
  /// [database] supplies storage and [profileId] limits its visible tasks.
  DriftTaskRepository(this._database, this._profileId);

  final AppDatabase _database;
  final String _profileId;

  @override
  Future<void> createTask(Task task) async {
    _validateForInsert(task);

    await _database
        .into(_database.localTasks)
        .insert(
          LocalTasksCompanion(
            id: Value(task.id),
            profileId: Value(_profileId),
            topic: Value(task.topic),
            subtopic: Value(task.subtopic),
            description: Value(task.description),
            startDate: Value(task.startDate.toStorageString()),
            plannedEndDate: Value(task.plannedEndDate.toStorageString()),
            maximumEndDate: Value(task.maximumEndDate?.toStorageString()),
            effortHundredths: Value(task.effortHundredths),
            status: Value(_statusToStorage(task.status)),
            completedAtUtc: Value(task.completedAt?.toUtc()),
            createdAtUtc: Value(task.createdAt.toUtc()),
            updatedAtUtc: Value(task.updatedAt.toUtc()),
          ),
        );
  }

  @override
  Future<Task?> getTask(String taskId) async {
    final row = await _findRow(taskId);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<bool> updateTask(Task task) async {
    _validateTaskFields(task);
    final current = await _findRow(task.id);
    if (current == null) return false;

    final currentStatus = _statusFromStorage(current.status);
    if (task.status != currentStatus ||
        task.completedAt?.toUtc() != current.completedAtUtc?.toUtc()) {
      throw ArgumentError.value(
        task.status,
        'task.status',
        'Use a lifecycle operation to complete or reopen a task.',
      );
    }

    final updatedRows =
        await (_database.update(_database.localTasks)..where(
              (row) =>
                  row.id.equals(task.id) & row.profileId.equals(_profileId),
            ))
            .write(
              LocalTasksCompanion(
                topic: Value(task.topic),
                subtopic: Value(task.subtopic),
                description: Value(task.description),
                startDate: Value(task.startDate.toStorageString()),
                plannedEndDate: Value(task.plannedEndDate.toStorageString()),
                maximumEndDate: Value(task.maximumEndDate?.toStorageString()),
                effortHundredths: Value(task.effortHundredths),
                updatedAtUtc: Value(task.updatedAt.toUtc()),
              ),
            );
    return updatedRows > 0;
  }

  @override
  Future<bool> deleteTask(String taskId) async {
    final deletedRows =
        await (_database.delete(_database.localTasks)..where(
              (task) =>
                  task.id.equals(taskId) & task.profileId.equals(_profileId),
            ))
            .go();
    return deletedRows > 0;
  }

  @override
  Stream<List<Task>> watchTasks() {
    return (_database.select(_database.localTasks)
          ..where((task) => task.profileId.equals(_profileId))
          ..orderBy([
            (task) => OrderingTerm.asc(task.startDate),
            (task) => OrderingTerm.asc(task.plannedEndDate),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  void _validateForInsert(Task task) {
    _validateTaskFields(task);

    if (task.status != TaskStatus.open || task.completedAt != null) {
      throw ArgumentError.value(
        task.status,
        'task.status',
        'A newly created task must be open and have no completion time.',
      );
    }
  }

  void _validateTaskFields(Task task) {
    if (task.profileId != _profileId) {
      throw StateError('A task cannot be saved under a different profile.');
    }
    if (task.id.trim().isEmpty) {
      throw ArgumentError.value(task.id, 'task.id', 'Task ID cannot be empty.');
    }

    final errors = TaskRules.validateTask(
      topic: task.topic,
      subtopic: task.subtopic,
      description: task.description,
      startDate: task.startDate,
      plannedEndDate: task.plannedEndDate,
      maximumEndDate: task.maximumEndDate,
      effortInput: _effortInput(task.effortHundredths),
    );
    if (errors.isNotEmpty) {
      throw ArgumentError.value(errors, 'task', 'Task data is invalid.');
    }
  }

  Future<TaskRecord?> _findRow(String taskId) =>
      (_database.select(_database.localTasks)..where(
            (task) =>
                task.id.equals(taskId) & task.profileId.equals(_profileId),
          ))
          .getSingleOrNull();

  String _effortInput(int hundredths) {
    if (hundredths < 0) return '-1';
    final hours = hundredths ~/ 100;
    final fraction = (hundredths % 100).toString().padLeft(2, '0');
    return '$hours.$fraction';
  }

  String _statusToStorage(TaskStatus status) => switch (status) {
    TaskStatus.open => 'OPEN',
    TaskStatus.completed => 'COMPLETED',
  };

  TaskStatus _statusFromStorage(String status) => switch (status) {
    'OPEN' => TaskStatus.open,
    'COMPLETED' => TaskStatus.completed,
    _ => throw StateError('The database contains an unknown task status.'),
  };

  Task _toDomain(TaskRecord row) => Task(
    id: row.id,
    profileId: row.profileId,
    topic: row.topic,
    subtopic: row.subtopic,
    description: row.description,
    startDate: TaskDate.parse(row.startDate),
    plannedEndDate: TaskDate.parse(row.plannedEndDate),
    maximumEndDate: row.maximumEndDate == null
        ? null
        : TaskDate.parse(row.maximumEndDate!),
    effortHundredths: row.effortHundredths,
    status: _statusFromStorage(row.status),
    completedAt: row.completedAtUtc?.toUtc(),
    createdAt: row.createdAtUtc.toUtc(),
    updatedAt: row.updatedAtUtc.toUtc(),
  );
}
