import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/progress/progress_use_cases.dart';
import '../data/local/database_providers.dart';
import '../data/local/progress_repository_provider.dart';

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
