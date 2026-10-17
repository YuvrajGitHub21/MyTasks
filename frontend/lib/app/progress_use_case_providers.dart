import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/progress/progress_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/progress_repository_provider.dart';
import '../domain/entities/progress_entry.dart';

/// Composition root for progress actions and queries.
final recordProgressUseCaseProvider = FutureProvider<RecordProgress>((
  ref,
) async {
  final repository = await ref.watch(progressRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  return RecordProgress(repository, profile.id);
});

final watchProgressHistoryUseCaseProvider =
    FutureProvider<WatchProgressHistory>((ref) async {
      final repository = await ref.watch(progressRepositoryProvider.future);
      return WatchProgressHistory(repository);
    });

final progressHistoryProvider =
    StreamProvider.family<List<ProgressEntry>, String>((ref, taskId) async* {
      final watchHistory = await ref.watch(
        watchProgressHistoryUseCaseProvider.future,
      );
      yield* watchHistory(taskId);
    });

final correctProgressEntryUseCaseProvider =
    FutureProvider<CorrectProgressEntry>((ref) async {
      final repository = await ref.watch(progressRepositoryProvider.future);
      return CorrectProgressEntry(repository);
    });

final deleteProgressEntryUseCaseProvider = FutureProvider<DeleteProgressEntry>((
  ref,
) async {
  final repository = await ref.watch(progressRepositoryProvider.future);
  return DeleteProgressEntry(repository);
});
