import '../entities/progress_entry.dart';

/// Persistence port owned by the domain and implemented by outer adapters.
abstract interface class ProgressRepository {
  Future<void> createEntry(ProgressEntry entry);

  Future<ProgressEntry?> getEntry(String entryId);

  /// Emits one task's progress history, newest occurrence first.
  Stream<List<ProgressEntry>> watchEntriesForTask(String taskId);

  /// Updates a progress entry without changing its owning task or profile.
  Future<bool> updateEntry(ProgressEntry entry);

  Future<bool> deleteEntry(String entryId);
}
