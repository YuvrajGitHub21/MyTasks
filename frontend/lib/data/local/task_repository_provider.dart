import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_providers.dart';
import 'drift_task_repository.dart';
import 'task_repository.dart';

/// Builds a task repository after the database and active profile are ready.
final taskRepositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return DriftTaskRepository(database, profile.id);
});
