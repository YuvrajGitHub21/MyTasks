import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/rules/task_rules.dart';
import '../../domain/services/diagnostic_logger.dart';

/// Application action for creating a task after checking domain constraints.
final class CreateTask {
  CreateTask(
    this._tasks,
    this._profileId, {
    DateTime Function()? clock,
    Future<void> Function()? onChanged,
    this._logger = const NoopDiagnosticLogger(),
  }) : _clock = clock ?? DateTime.now,
       _onChanged = onChanged;

  static const _uuid = Uuid();

  final TaskRepository _tasks;
  final String _profileId;
  final DateTime Function() _clock;
  final Future<void> Function()? _onChanged;
  final DiagnosticLogger _logger;

  Future<Task> call(CreateTaskInput input) => runDiagnosticOperation(
    logger: _logger,
    feature: 'tasks',
    eventName: 'task.create',
    action: () async {
      final errors = TaskRules.validateTask(
        topic: input.topic,
        subtopic: input.subtopic,
        description: input.description,
        startDate: input.startDate,
        plannedEndDate: input.plannedEndDate,
        maximumEndDate: input.maximumEndDate,
        effortInput: input.effortInput,
      );
      if (errors.isNotEmpty) throw TaskValidationException(errors);

      final now = _clock().toUtc();
      final task = Task(
        id: _uuid.v4(),
        profileId: _profileId,
        topic: input.topic.trim(),
        subtopic: _optionalText(input.subtopic),
        description: _optionalText(input.description),
        startDate: input.startDate!,
        plannedEndDate: input.plannedEndDate!,
        maximumEndDate: input.maximumEndDate,
        effortHundredths: TaskRules.effortHundredthsFromInput(
          input.effortInput,
        )!,
        status: TaskStatus.open,
        createdAt: now,
        updatedAt: now,
      );
      await _tasks.createTask(task);
      await _onChanged?.call();
      return task;
    },
  );

  String? _optionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// User-entered values needed by the create-task application action.
final class CreateTaskInput {
  const CreateTaskInput({
    required this.topic,
    this.subtopic,
    this.description,
    required this.startDate,
    required this.plannedEndDate,
    this.maximumEndDate,
    required this.effortInput,
  });

  final String topic;
  final String? subtopic;
  final String? description;
  final TaskDate? startDate;
  final TaskDate? plannedEndDate;
  final TaskDate? maximumEndDate;
  final String effortInput;
}

/// Application query for opening a task's details without exposing storage.
final class GetTask {
  const GetTask(
    this._tasks, {
    this._logger = const NoopDiagnosticLogger(),
  });

  final TaskRepository _tasks;
  final DiagnosticLogger _logger;

  Future<Task?> call(String taskId) => runDiagnosticOperation(
    logger: _logger,
    feature: 'tasks',
    eventName: 'task.read',
    action: () => _tasks.getTask(taskId),
  );
}

/// Application action for changing editable fields on an existing task.
final class UpdateTask {
  UpdateTask(
    this._tasks, {
    DateTime Function()? clock,
    Future<void> Function()? onChanged,
    this._logger = const NoopDiagnosticLogger(),
  }) : _clock = clock ?? DateTime.now,
       _onChanged = onChanged;

  final TaskRepository _tasks;
  final DateTime Function() _clock;
  final Future<void> Function()? _onChanged;
  final DiagnosticLogger _logger;

  Future<bool> call(UpdateTaskInput input) => runDiagnosticOperation(
    logger: _logger,
    feature: 'tasks',
    eventName: 'task.update',
    action: () async {
      final current = await _tasks.getTask(input.taskId);
      if (current == null) return false;

      final errors = TaskRules.validateTask(
        topic: input.topic,
        subtopic: input.subtopic,
        description: input.description,
        startDate: input.startDate,
        plannedEndDate: input.plannedEndDate,
        maximumEndDate: input.maximumEndDate,
        effortInput: input.effortInput,
      );
      if (errors.isNotEmpty) throw TaskValidationException(errors);

      final updatedTask = Task(
        id: current.id,
        profileId: current.profileId,
        topic: input.topic.trim(),
        subtopic: _optionalText(input.subtopic),
        description: _optionalText(input.description),
        startDate: input.startDate!,
        plannedEndDate: input.plannedEndDate!,
        maximumEndDate: input.maximumEndDate,
        effortHundredths: TaskRules.effortHundredthsFromInput(
          input.effortInput,
        )!,
        status: current.status,
        completedAt: current.completedAt,
        createdAt: current.createdAt,
        updatedAt: _clock().toUtc(),
      );
      final updated = await _tasks.updateTask(updatedTask);
      if (updated) await _onChanged?.call();
      return updated;
    },
  );

  String? _optionalText(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

final class UpdateTaskInput {
  const UpdateTaskInput({
    required this.taskId,
    required this.topic,
    this.subtopic,
    this.description,
    required this.startDate,
    required this.plannedEndDate,
    this.maximumEndDate,
    required this.effortInput,
  });

  final String taskId;
  final String topic;
  final String? subtopic;
  final String? description;
  final TaskDate? startDate;
  final TaskDate? plannedEndDate;
  final TaskDate? maximumEndDate;
  final String effortInput;
}

/// Application action for deleting a task and its dependent history.
final class DeleteTask {
  const DeleteTask(
    this._tasks, {
    this._onChanged,
    this._logger = const NoopDiagnosticLogger(),
  });

  final TaskRepository _tasks;
  final Future<void> Function()? _onChanged;
  final DiagnosticLogger _logger;

  Future<bool> call(String taskId) => runDiagnosticOperation(
    logger: _logger,
    feature: 'tasks',
    eventName: 'task.delete',
    action: () async {
      final deleted = await _tasks.deleteTask(taskId);
      if (deleted) await _onChanged?.call();
      return deleted;
    },
  );
}

/// Application query that returns tasks for one of the three primary views.
final class WatchTasksByCategory {
  const WatchTasksByCategory(this._tasks);

  final TaskRepository _tasks;

  Stream<List<Task>> call(TaskCategory category, {TaskDate? today}) {
    final referenceDate = today ?? TaskDate.todayInIst();
    return _tasks.watchTasks().map((tasks) {
      final matching = tasks.where((task) {
        final actualCategory = TaskRules.classify(task, referenceDate);
        return switch (category) {
          TaskCategory.current =>
            actualCategory == TaskCategory.current ||
                actualCategory == TaskCategory.overdue,
          TaskCategory.scheduled => actualCategory == TaskCategory.scheduled,
          TaskCategory.completed => actualCategory == TaskCategory.completed,
          TaskCategory.overdue => actualCategory == TaskCategory.overdue,
        };
      }).toList();

      if (category == TaskCategory.completed) {
        matching.sort((a, b) {
          final completionOrder = (b.completedAt ?? b.updatedAt).compareTo(
            a.completedAt ?? a.updatedAt,
          );
          return completionOrder != 0 ? completionOrder : a.id.compareTo(b.id);
        });
      }
      return List.unmodifiable(matching);
    });
  }
}

/// Carries field-level validation errors from an application action to UI.
final class TaskValidationException implements Exception {
  const TaskValidationException(this.errors);

  final Map<String, String> errors;

  @override
  String toString() => 'Task validation failed: ${errors.values.join(' ')}';
}
