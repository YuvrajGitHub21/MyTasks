import '../../domain/entities/reminder_request.dart';
import '../../domain/services/notification_scheduler.dart';
import 'calculate_desired_reminders.dart';

/// Replaces the OS schedule with the current desired set for one profile.
final class ReconcileReminders {
  factory ReconcileReminders({
    required CalculateDesiredReminders calculateDesired,
    required NotificationScheduler scheduler,
  }) => ReconcileReminders._(
    calculateDesired: calculateDesired,
    scheduler: scheduler,
  );

  const ReconcileReminders._({
    required this._calculateDesired,
    required this._scheduler,
  });

  final CalculateDesiredReminders _calculateDesired;
  final NotificationScheduler _scheduler;

  Future<List<ReminderRequest>> call(String profileId) async {
    final desired = await _calculateDesired(profileId);
    await _scheduler.replaceScheduledRequests(profileId, desired);
    return desired;
  }
}
