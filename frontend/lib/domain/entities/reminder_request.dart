import 'reminder_preferences.dart';
import 'task.dart';

enum ReminderSlot { morning, midday, endOfDay }

enum ReminderContentKind { dailySummary, assignTask, logToday }

/// A desired one-shot notification, before an OS-specific integer ID is added.
///
/// [scheduledAtUtc] is an instant. The configured slot and [date] preserve the
/// logical IST identity even if quiet hours move the delivery time.
final class ReminderRequest {
  const ReminderRequest({
    required this.profileId,
    required this.slot,
    required this.contentKind,
    required this.date,
    required this.configuredTime,
    required this.scheduledAtUtc,
    this.taskCount,
  });

  final String profileId;
  final ReminderSlot slot;
  final ReminderContentKind contentKind;
  final TaskDate date;
  final ReminderTime configuredTime;
  final DateTime scheduledAtUtc;
  final int? taskCount;

  /// Stable key shared by alternate content for the same logical slot.
  String get identity =>
      '$profileId/${slot.name}/${date.toStorageString()}/'
      '${configuredTime.minutesAfterMidnight.toString().padLeft(4, '0')}';
}
