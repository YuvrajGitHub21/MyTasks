import 'reminder_request.dart';

/// A desired reminder paired with the stable integer ID used by the OS plugin.
final class ScheduledReminderRecord {
  const ScheduledReminderRecord({
    required this.request,
    required this.notificationId,
    required this.updatedAtUtc,
  });

  final ReminderRequest request;
  final int notificationId;
  final DateTime updatedAtUtc;
}
