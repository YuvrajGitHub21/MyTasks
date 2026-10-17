import '../entities/reminder_request.dart';

/// Outbound port for scheduling local OS notifications.
///
/// The platform adapter will implement this with the notification plugin.
/// Domain and application code describe desired reminders without importing
/// Flutter or Android/iOS APIs.
abstract interface class NotificationScheduler {
  /// Replaces pending requests for [profileId] with this desired set.
  /// Implementations must use each request's stable identity to avoid dupes.
  Future<void> replaceScheduledRequests(
    String profileId,
    List<ReminderRequest> requests,
  );

  Future<void> cancelAll(String profileId);
}
