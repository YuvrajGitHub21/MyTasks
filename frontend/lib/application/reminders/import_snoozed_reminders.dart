import 'dart:convert';

import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/snoozed_reminder_record.dart';
import '../../domain/repositories/scheduled_reminder_repository.dart';
import '../../domain/repositories/snoozed_reminder_repository.dart';
import '../../domain/services/snoozed_reminder_event_source.dart';

/// Copies OS-created snoozes into the encrypted ledger before reconciliation.
final class ImportSnoozedReminders {
  factory ImportSnoozedReminders({
    required SnoozedReminderEventSource eventSource,
    required ScheduledReminderRepository scheduledRepository,
    required SnoozedReminderRepository snoozedRepository,
  }) => ImportSnoozedReminders._(
    eventSource: eventSource,
    scheduledRepository: scheduledRepository,
    snoozedRepository: snoozedRepository,
  );

  const ImportSnoozedReminders._({
    required this._eventSource,
    required this._scheduledRepository,
    required this._snoozedRepository,
  });

  final SnoozedReminderEventSource _eventSource;
  final ScheduledReminderRepository _scheduledRepository;
  final SnoozedReminderRepository _snoozedRepository;

  Future<int> call(String profileId) async {
    final events = await _eventSource.getPendingEvents();
    if (events.isEmpty) return 0;

    final parents = await _scheduledRepository.getRequests(profileId);
    final parentsById = {
      for (final parent in parents) parent.notificationId.toString(): parent,
    };
    var importedCount = 0;

    for (final event in events) {
      final payload = jsonDecode(event.payload);
      if (payload is! Map<String, dynamic> || payload['version'] != 1) {
        throw const FormatException('Unsupported snooze event payload.');
      }
      final identity = payload['identity'];
      final contentKindName = payload['contentKind'];
      if (identity is! String || contentKindName is! String) {
        throw const FormatException('Snooze event routing fields are missing.');
      }
      final parent = parentsById[event.parentPlatformAlarmId];
      if (parent == null || parent.request.identity != identity) {
        // The parent was removed before this queued event could be imported.
        await _eventSource.acknowledge(event.platformAlarmId);
        continue;
      }
      ReminderContentKind? contentKind;
      for (final candidate in ReminderContentKind.values) {
        if (candidate.name == contentKindName) {
          contentKind = candidate;
          break;
        }
      }
      if (contentKind == null ||
          contentKind == ReminderContentKind.dailySummary ||
          contentKind != parent.request.contentKind) {
        throw const FormatException('Snooze event content kind is invalid.');
      }

      await _snoozedRepository.save(
        SnoozedReminderRecord(
          occurrenceId: '$profileId:${event.platformAlarmId}',
          platformAlarmId: event.platformAlarmId,
          profileId: profileId,
          parentIdentity: parent.request.identity,
          contentKind: contentKind,
          scheduledAtUtc: event.scheduledAtUtc.toUtc(),
          createdAtUtc: event.createdAtUtc.toUtc(),
        ),
      );
      // A failed acknowledgement is safe: save() is an upsert by occurrence ID.
      await _eventSource.acknowledge(event.platformAlarmId);
      importedCount++;
    }
    return importedCount;
  }
}
