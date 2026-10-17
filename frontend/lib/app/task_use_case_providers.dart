import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks/task_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/task_repository_provider.dart';
import '../domain/entities/task.dart';

/// Composition root: connects application actions to outer data adapters.
final createTaskUseCaseProvider = FutureProvider<CreateTask>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return CreateTask(repository, profile.id);
});

final watchTasksUseCaseProvider = FutureProvider<WatchTasksByCategory>((
  ref,
) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return WatchTasksByCategory(repository);
});

/// UI-facing stream provider; data adapter details stay in this composition file.
final taskListProvider = StreamProvider.family<List<Task>, TaskCategory>((
  ref,
  category,
) async* {
  final watchTasks = await ref.watch(watchTasksUseCaseProvider.future);
  yield* watchTasks(category);
});
