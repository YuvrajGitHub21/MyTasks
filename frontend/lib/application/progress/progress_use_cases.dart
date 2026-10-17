import 'package:uuid/uuid.dart';

import '../../domain/entities/progress_entry.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/rules/task_rules.dart';

/// Application action that validates and records one partial-progress event.
final class RecordProgress {
  RecordProgress(
    this._progress,
    this._profileId, {
    DateTime Function()? clock,
    Future<void> Function()? onChanged,
  }) : _clock = clock ?? DateTime.now,
       _onChanged = onChanged;

  static const _uuid = Uuid();

  final ProgressRepository _progress;
  final String _profileId;
  final DateTime Function() _clock;
  final Future<void> Function()? _onChanged;

  Future<ProgressEntry> call(RecordProgressInput input) async {
    final now = _clock().toUtc();
    final entry = ProgressEntry(
      id: _uuid.v4(),
      taskId: input.taskId,
      profileId: _profileId,
      method: input.method,
      percentComplete: input.percentComplete,
      completedUnits: input.completedUnits,
      totalUnits: input.totalUnits,
      note: input.note,
      occurredAt: (input.occurredAt ?? now).toUtc(),
      createdAt: now,
      updatedAt: now,
    );
    final errors = TaskRules.validateProgress(entry);
    if (input.taskId.trim().isEmpty) {
      errors['taskId'] = 'Choose a task for this progress entry.';
    }
    if (errors.isNotEmpty) throw ProgressValidationException(errors);

    await _progress.createEntry(entry);
    await _onChanged?.call();
    return entry;
  }
}

/// Application query for a task's chronological partial-progress history.
final class WatchProgressHistory {
  const WatchProgressHistory(this._progress);

  final ProgressRepository _progress;

  Stream<List<ProgressEntry>> call(String taskId) =>
      _progress.watchEntriesForTask(taskId);
}

/// Application action for correcting an existing progress entry.
final class CorrectProgressEntry {
  const CorrectProgressEntry(this._progress, {this._onChanged});

  final ProgressRepository _progress;
  final Future<void> Function()? _onChanged;

  Future<bool> call(ProgressEntry entry) async {
    final errors = TaskRules.validateProgress(entry);
    if (errors.isNotEmpty) throw ProgressValidationException(errors);
    final updated = await _progress.updateEntry(entry);
    if (updated) await _onChanged?.call();
    return updated;
  }
}

final class DeleteProgressEntry {
  const DeleteProgressEntry(this._progress, {this._onChanged});

  final ProgressRepository _progress;
  final Future<void> Function()? _onChanged;

  Future<bool> call(String entryId) async {
    final deleted = await _progress.deleteEntry(entryId);
    if (deleted) await _onChanged?.call();
    return deleted;
  }
}

/// Input from presentation for a new progress event; IDs and ownership stay
/// under application/profile control.
final class RecordProgressInput {
  const RecordProgressInput({
    required this.taskId,
    required this.method,
    this.percentComplete,
    this.completedUnits,
    this.totalUnits,
    this.note,
    this.occurredAt,
  });

  final String taskId;
  final ProgressMethod method;
  final int? percentComplete;
  final int? completedUnits;
  final int? totalUnits;
  final String? note;
  final DateTime? occurredAt;
}

final class ProgressValidationException implements Exception {
  const ProgressValidationException(this.errors);

  final Map<String, String> errors;

  @override
  String toString() => 'Progress validation failed: ${errors.values.join(' ')}';
}
