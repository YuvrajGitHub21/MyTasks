import '../entities/task.dart';

/// Storage boundary owned by the domain and implemented by outer adapters.
///
/// Application code depends on this contract, never on Drift or SQLite.
abstract interface class TaskRepository {
  /// Saves a new task. A task owned by a different profile must be rejected.
  Future<void> createTask(Task task);

  /// Updates editable task fields without changing its completion lifecycle.
  /// Returns false if the task does not exist in this profile.
  Future<bool> updateTask(Task task);

  /// Deletes a task and cascades to its progress and lifecycle history.
  /// Returns false if the task does not exist in this profile.
  Future<bool> deleteTask(String taskId);

  /// Returns a task only when it belongs to this repository's profile.
  Future<Task?> getTask(String taskId);

  /// Emits this profile's tasks, ordered by start date and planned end date.
  Stream<List<Task>> watchTasks();
}
