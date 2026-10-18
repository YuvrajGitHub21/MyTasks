import 'reminder_request.dart';

/// A one-off snooze occurrence, kept separate from its daily reminder slot.
///
/// [platformAlarmId] is the identifier assigned by Android AlarmManager or
/// Apple AlarmKit. It contains no task text or other user-entered content.
final class SnoozedReminderRecord {
  const SnoozedReminderRecord({
    required this.occurrenceId,
    required this.platformAlarmId,
    required this.profileId,
    required this.parentIdentity,
    required this.contentKind,
    required this.scheduledAtUtc,
    required this.createdAtUtc,
  });

  final String occurrenceId;
  final String platformAlarmId;
  final String profileId;
  final String parentIdentity;
  final ReminderContentKind contentKind;
  final DateTime scheduledAtUtc;
  final DateTime createdAtUtc;
}
