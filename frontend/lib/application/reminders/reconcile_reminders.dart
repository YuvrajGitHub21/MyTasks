import '../../domain/entities/reminder_request.dart';
import '../../domain/services/notification_scheduler.dart';
import '../../domain/services/diagnostic_logger.dart';
import 'calculate_desired_reminders.dart';

/// Replaces the OS schedule with the current desired set for one profile.
final class ReconcileReminders {
  factory ReconcileReminders({
    required CalculateDesiredReminders calculateDesired,
    required NotificationScheduler scheduler,
    DiagnosticLogger logger = const NoopDiagnosticLogger(),
  }) => ReconcileReminders._(
    calculateDesired: calculateDesired,
    scheduler: scheduler,
    logger: logger,
  );

  const ReconcileReminders._({
    required this._calculateDesired,
    required this._scheduler,
    required this._logger,
  });

  final CalculateDesiredReminders _calculateDesired;
  final NotificationScheduler _scheduler;
  final DiagnosticLogger _logger;

  Future<List<ReminderRequest>> call(String profileId) =>
      runDiagnosticOperation(
        logger: _logger,
        feature: 'reminders',
        eventName: 'reminder.schedule',
        action: () async {
          final desired = await _calculateDesired(profileId);
          await _scheduler.replaceScheduledRequests(profileId, desired);
          return desired;
        },
      );
}
