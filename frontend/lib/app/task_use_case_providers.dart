import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/tasks/task_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/task_repository_provider.dart';
import '../domain/entities/task.dart';
import 'reminder_reconciliation_callbacks.dart';
import 'diagnostic_logger_provider.dart';

/// Composition root: connects application actions to outer data adapters.
final createTaskUseCaseProvider = FutureProvider<CreateTask>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  final logger = ref.watch(diagnosticLoggerProvider);
  return CreateTask(
    repository,
    profile.id,
    onChanged: () => reconcileRemindersAfterChange(ref, profile.id),
    logger: logger,
  );
});

final watchTasksUseCaseProvider = FutureProvider<WatchTasksByCategory>((
  ref,
) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return WatchTasksByCategory(repository);
});

final getTaskUseCaseProvider = FutureProvider<GetTask>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return GetTask(repository);
});

final updateTaskUseCaseProvider = FutureProvider<UpdateTask>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  final logger = ref.watch(diagnosticLoggerProvider);
  return UpdateTask(
    repository,
    onChanged: () => reconcileRemindersAfterChange(ref, profile.id),
    logger: logger,
  );
});

final deleteTaskUseCaseProvider = FutureProvider<DeleteTask>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  final logger = ref.watch(diagnosticLoggerProvider);
  return DeleteTask(
    repository,
    onChanged: () => reconcileRemindersAfterChange(ref, profile.id),
    logger: logger,
  );
});

final taskDetailsProvider = FutureProvider.family<Task?, String>((
  ref,
  taskId,
) async {
  final getTask = await ref.watch(getTaskUseCaseProvider.future);
  return getTask(taskId);
});

/// UI-facing stream provider; data adapter details stay in this composition file.
final taskListProvider = StreamProvider.family<List<Task>, TaskCategory>((
  ref,
  category,
) async* {
  // Rebuild the category query at IST midnight, even if SQLite has no writes.
  final midnightTimer = Timer(
    _durationUntilNextIstMidnight(),
    ref.invalidateSelf,
  );
  ref.onDispose(midnightTimer.cancel);

  // A timer may be delayed while Android suspends the app. Refresh immediately
  // when the user returns so Today/Later use the current IST date.
  final lifecycleObserver = _TaskListLifecycleObserver(ref.invalidateSelf);
  WidgetsBinding.instance.addObserver(lifecycleObserver);
  ref.onDispose(
    () => WidgetsBinding.instance.removeObserver(lifecycleObserver),
  );

  final watchTasks = await ref.watch(watchTasksUseCaseProvider.future);
  yield* watchTasks(category);
});

Duration _durationUntilNextIstMidnight() {
  const istOffset = Duration(hours: 5, minutes: 30);
  final utcNow = DateTime.now().toUtc();
  final istNow = utcNow.add(istOffset);
  final nextIstMidnight = DateTime.utc(
    istNow.year,
    istNow.month,
    istNow.day + 1,
  );
  final nextMidnightUtc = nextIstMidnight.subtract(istOffset);
  return nextMidnightUtc.difference(utcNow);
}

class _TaskListLifecycleObserver with WidgetsBindingObserver {
  _TaskListLifecycleObserver(this._onResume);

  final VoidCallback _onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onResume();
  }
}
