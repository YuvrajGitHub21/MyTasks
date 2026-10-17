import 'package:drift/drift.dart';

import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/reminder_preferences.dart';
import '../../domain/entities/scheduled_reminder_record.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/scheduled_reminder_repository.dart';
import 'app_database.dart';

/// Drift adapter that allocates collision-free OS IDs and preserves stale rows
/// until the notification adapter confirms that their OS requests are canceled.
final class DriftScheduledReminderRepository
    implements ScheduledReminderRepository {
  DriftScheduledReminderRepository(this._database);

  static const _maximumNotificationId = 2147483647;

  final AppDatabase _database;

  @override
  Future<List<ScheduledReminderRecord>> getRequests(String profileId) async {
    final rows =
        await (_database.select(_database.scheduledReminderRequests)
              ..where((request) => request.profileId.equals(profileId))
              ..orderBy([
                (request) => OrderingTerm.asc(request.scheduledAtUtc),
              ]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<List<ScheduledReminderRecord>> upsertDesiredRequests({
    required String profileId,
    required List<ReminderRequest> requests,
    required DateTime updatedAtUtc,
  }) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'Cannot be empty.');
    }
    if (requests.any((request) => request.profileId != profileId)) {
      throw StateError('A reminder cannot be saved under a different profile.');
    }
    final identities = requests.map((request) => request.identity).toSet();
    if (identities.length != requests.length) {
      throw ArgumentError('Desired reminders must have unique identities.');
    }

    return _database.transaction(() async {
      final allRows = await _database
          .select(_database.scheduledReminderRequests)
          .get();
      final ownerByIdentity = {
        for (final row in allRows) row.identity: row.profileId,
      };
      if (requests.any(
        (request) =>
            ownerByIdentity[request.identity] != null &&
            ownerByIdentity[request.identity] != profileId,
      )) {
        throw StateError(
          'A reminder identity is already owned by another profile.',
        );
      }
      final rowsForProfile = allRows
          .where((row) => row.profileId == profileId)
          .toList(growable: false);
      final existingByIdentity = {
        for (final row in rowsForProfile) row.identity: row,
      };
      final usedIds = allRows.map((row) => row.notificationId).toSet();
      var nextCandidate = 1;
      final records = <ScheduledReminderRecord>[];

      for (final request in requests) {
        final existing = existingByIdentity[request.identity];
        final notificationId =
            existing?.notificationId ??
            _nextAvailableId(usedIds, () => nextCandidate++);
        usedIds.add(notificationId);
        final record = ScheduledReminderRecord(
          request: request,
          notificationId: notificationId,
          updatedAtUtc: updatedAtUtc.toUtc(),
        );

        await _database
            .into(_database.scheduledReminderRequests)
            .insertOnConflictUpdate(_toCompanion(record));
        records.add(record);
      }
      return List.unmodifiable(records);
    });
  }

  @override
  Future<void> deleteRequests({
    required String profileId,
    required Set<String> identities,
  }) async {
    if (identities.isEmpty) return;
    await (_database.delete(_database.scheduledReminderRequests)..where(
          (request) =>
              request.profileId.equals(profileId) &
              request.identity.isIn(identities),
        ))
        .go();
  }

  int _nextAvailableId(Set<int> usedIds, int Function() nextCandidate) {
    var candidate = nextCandidate();
    while (usedIds.contains(candidate)) {
      if (candidate >= _maximumNotificationId) {
        throw StateError('No local notification IDs are available.');
      }
      candidate = nextCandidate();
    }
    if (candidate > _maximumNotificationId) {
      throw StateError('No local notification IDs are available.');
    }
    return candidate;
  }

  ScheduledReminderRequestsCompanion _toCompanion(
    ScheduledReminderRecord record,
  ) {
    final request = record.request;
    return ScheduledReminderRequestsCompanion(
      identity: Value(request.identity),
      notificationId: Value(record.notificationId),
      profileId: Value(request.profileId),
      slot: Value(request.slot.name),
      contentKind: Value(request.contentKind.name),
      istDate: Value(request.date.toStorageString()),
      configuredTimeMinutes: Value(request.configuredTime.minutesAfterMidnight),
      scheduledAtUtc: Value(request.scheduledAtUtc.toUtc()),
      updatedAtUtc: Value(record.updatedAtUtc.toUtc()),
    );
  }

  ScheduledReminderRecord _toDomain(ScheduledReminderRequestRecord row) {
    final request = ReminderRequest(
      profileId: row.profileId,
      slot: ReminderSlot.values.byName(row.slot),
      contentKind: ReminderContentKind.values.byName(row.contentKind),
      date: TaskDate.parse(row.istDate),
      configuredTime: ReminderTime(row.configuredTimeMinutes),
      scheduledAtUtc: row.scheduledAtUtc.toUtc(),
    );
    if (request.identity != row.identity) {
      throw StateError('The reminder ledger contains an invalid identity.');
    }
    return ScheduledReminderRecord(
      request: request,
      notificationId: row.notificationId,
      updatedAtUtc: row.updatedAtUtc.toUtc(),
    );
  }
}
