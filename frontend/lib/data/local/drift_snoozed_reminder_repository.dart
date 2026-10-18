import 'package:drift/drift.dart';

import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/snoozed_reminder_record.dart';
import '../../domain/repositories/snoozed_reminder_repository.dart';
import 'app_database.dart' as db;

/// Drift adapter for snoozed reminders stored in the encrypted local database.
final class DriftSnoozedReminderRepository
    implements SnoozedReminderRepository {
  DriftSnoozedReminderRepository(this._database);

  final db.AppDatabase _database;

  @override
  Future<List<SnoozedReminderRecord>> getForProfile(String profileId) async {
    final rows =
        await (_database.select(_database.snoozedReminderRecords)
              ..where((row) => row.profileId.equals(profileId))
              ..orderBy([(row) => OrderingTerm.asc(row.scheduledAtUtc)]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<void> save(SnoozedReminderRecord record) async {
    if (record.profileId.trim().isEmpty ||
        record.occurrenceId.trim().isEmpty ||
        record.platformAlarmId.trim().isEmpty) {
      throw ArgumentError('Snooze identity and profile must not be empty.');
    }
    if (record.contentKind == ReminderContentKind.dailySummary) {
      throw ArgumentError('Daily summaries cannot be snoozed as alarms.');
    }

    await _database.transaction(() async {
      final parent =
          await (_database.select(_database.scheduledReminderRequests)
                ..where((row) => row.identity.equals(record.parentIdentity)))
              .getSingleOrNull();
      if (parent == null || parent.profileId != record.profileId) {
        throw StateError(
          'Snooze parent reminder does not belong to this profile.',
        );
      }
      await _database
          .into(_database.snoozedReminderRecords)
          .insertOnConflictUpdate(
            db.SnoozedReminderRecordsCompanion.insert(
              occurrenceId: record.occurrenceId,
              platformAlarmId: record.platformAlarmId,
              profileId: record.profileId,
              parentIdentity: record.parentIdentity,
              contentKind: record.contentKind.name,
              scheduledAtUtc: record.scheduledAtUtc.toUtc(),
              createdAtUtc: record.createdAtUtc.toUtc(),
            ),
          );
    });
  }

  @override
  Future<void> delete({
    required String profileId,
    required Set<String> occurrenceIds,
  }) async {
    if (occurrenceIds.isEmpty) return;
    await (_database.delete(_database.snoozedReminderRecords)..where(
          (row) =>
              row.profileId.equals(profileId) &
              row.occurrenceId.isIn(occurrenceIds),
        ))
        .go();
  }

  SnoozedReminderRecord _toDomain(db.SnoozedReminderRecord row) =>
      SnoozedReminderRecord(
        occurrenceId: row.occurrenceId,
        platformAlarmId: row.platformAlarmId,
        profileId: row.profileId,
        parentIdentity: row.parentIdentity,
        contentKind: ReminderContentKind.values.byName(row.contentKind),
        scheduledAtUtc: row.scheduledAtUtc.toUtc(),
        createdAtUtc: row.createdAtUtc.toUtc(),
      );
}
