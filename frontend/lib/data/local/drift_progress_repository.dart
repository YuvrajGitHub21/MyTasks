import 'package:drift/drift.dart';

import '../../domain/entities/progress_entry.dart';
import '../../domain/rules/task_rules.dart';
import 'app_database.dart';
import 'progress_repository.dart';

/// Drift implementation for profile-scoped partial-progress history.
final class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._database, this._profileId);

  final AppDatabase _database;
  final String _profileId;

  @override
  Future<void> createEntry(ProgressEntry entry) async {
    _validate(entry);

    await _database.transaction(() async {
      final task =
          await (_database.select(_database.localTasks)..where(
                (row) =>
                    row.id.equals(entry.taskId) &
                    row.profileId.equals(_profileId),
              ))
              .getSingleOrNull();
      if (task == null) {
        throw StateError('The task does not exist in the active profile.');
      }

      await _database
          .into(_database.localProgressEntries)
          .insert(
            LocalProgressEntriesCompanion(
              id: Value(entry.id),
              profileId: Value(_profileId),
              taskId: Value(entry.taskId),
              method: Value(_methodToStorage(entry.method)),
              percentComplete: Value(entry.percentComplete),
              completedUnits: Value(entry.completedUnits),
              totalUnits: Value(entry.totalUnits),
              note: Value(entry.note),
              occurredAtUtc: Value(entry.occurredAt.toUtc()),
              createdAtUtc: Value(entry.createdAt.toUtc()),
              updatedAtUtc: Value(entry.updatedAt.toUtc()),
            ),
          );
    });
  }

  @override
  Future<ProgressEntry?> getEntry(String entryId) async {
    final row =
        await (_database.select(_database.localProgressEntries)..where(
              (entry) =>
                  entry.id.equals(entryId) & entry.profileId.equals(_profileId),
            ))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<List<ProgressEntry>> watchEntriesForTask(String taskId) {
    return (_database.select(_database.localProgressEntries)
          ..where(
            (entry) =>
                entry.profileId.equals(_profileId) &
                entry.taskId.equals(taskId),
          )
          ..orderBy([
            (entry) => OrderingTerm.desc(entry.occurredAtUtc),
            (entry) => OrderingTerm.desc(entry.id),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  @override
  Future<bool> updateEntry(ProgressEntry entry) async {
    _validate(entry);

    return _database.transaction(() async {
      final current =
          await (_database.select(_database.localProgressEntries)..where(
                (row) =>
                    row.id.equals(entry.id) & row.profileId.equals(_profileId),
              ))
              .getSingleOrNull();
      if (current == null) return false;
      if (current.taskId != entry.taskId) {
        throw ArgumentError.value(
          entry.taskId,
          'entry.taskId',
          'A progress entry cannot be moved to another task.',
        );
      }

      final updatedRows =
          await (_database.update(_database.localProgressEntries)..where(
                (row) =>
                    row.id.equals(entry.id) & row.profileId.equals(_profileId),
              ))
              .write(
                LocalProgressEntriesCompanion(
                  method: Value(_methodToStorage(entry.method)),
                  percentComplete: Value(entry.percentComplete),
                  completedUnits: Value(entry.completedUnits),
                  totalUnits: Value(entry.totalUnits),
                  note: Value(entry.note),
                  occurredAtUtc: Value(entry.occurredAt.toUtc()),
                  updatedAtUtc: Value(entry.updatedAt.toUtc()),
                ),
              );
      return updatedRows > 0;
    });
  }

  @override
  Future<bool> deleteEntry(String entryId) async {
    final deletedRows =
        await (_database.delete(_database.localProgressEntries)..where(
              (entry) =>
                  entry.id.equals(entryId) & entry.profileId.equals(_profileId),
            ))
            .go();
    return deletedRows > 0;
  }

  void _validate(ProgressEntry entry) {
    if (entry.profileId != _profileId) {
      throw StateError(
        'A progress entry cannot be saved under a different profile.',
      );
    }
    if (entry.id.trim().isEmpty || entry.taskId.trim().isEmpty) {
      throw ArgumentError('Progress entry ID and task ID cannot be empty.');
    }

    final errors = TaskRules.validateProgress(entry);
    if (errors.isNotEmpty) {
      throw ArgumentError.value(
        errors,
        'entry',
        'Progress entry data is invalid.',
      );
    }
  }

  String _methodToStorage(ProgressMethod method) => switch (method) {
    ProgressMethod.percent => 'PERCENT',
    ProgressMethod.units => 'UNITS',
    ProgressMethod.note => 'NOTE',
  };

  ProgressMethod _methodFromStorage(String method) => switch (method) {
    'PERCENT' => ProgressMethod.percent,
    'UNITS' => ProgressMethod.units,
    'NOTE' => ProgressMethod.note,
    _ => throw StateError('The database contains an unknown progress method.'),
  };

  ProgressEntry _toDomain(ProgressEntryRecord row) => ProgressEntry(
    id: row.id,
    taskId: row.taskId,
    profileId: row.profileId,
    method: _methodFromStorage(row.method),
    percentComplete: row.percentComplete,
    completedUnits: row.completedUnits,
    totalUnits: row.totalUnits,
    note: row.note,
    occurredAt: row.occurredAtUtc.toUtc(),
    createdAt: row.createdAtUtc.toUtc(),
    updatedAt: row.updatedAtUtc.toUtc(),
  );
}
