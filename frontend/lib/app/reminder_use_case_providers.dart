import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../application/reminders/calculate_desired_reminders.dart';
import '../application/reminders/reconcile_reminders.dart';
import '../application/reminders/reminder_clock.dart';
import '../application/reminders/save_reminder_preferences.dart';
import '../data/local/database_providers.dart';
import '../data/local/progress_repository_provider.dart';
import '../data/local/reminder_repository_providers.dart';
import '../data/local/task_repository_provider.dart';
import '../data/notifications/flutter_local_notification_scheduler.dart';
import '../domain/services/notification_scheduler.dart';
import 'reminder_reconciliation_callbacks.dart';

/// One clock instance is shared by reminder use cases in this provider scope.
final reminderClockProvider = Provider<ReminderClock>(
  (ref) => const SystemReminderClock(),
);

/// Composes domain ports into the application reminder calculator.
final calculateDesiredRemindersProvider =
    FutureProvider<CalculateDesiredReminders>((ref) async {
      final tasks = await ref.watch(taskRepositoryProvider.future);
      final progress = await ref.watch(progressRepositoryProvider.future);
      final preferences = await ref.watch(
        reminderPreferencesRepositoryProvider.future,
      );
      final clock = ref.watch(reminderClockProvider);
      return CalculateDesiredReminders(
        tasks: tasks,
        progress: progress,
        preferences: preferences,
        clock: clock,
      );
    });

/// Composes a profile-scoped action for saving reminder settings.
final saveReminderPreferencesProvider = FutureProvider<SaveReminderPreferences>(
  (ref) async {
    final preferences = await ref.watch(
      reminderPreferencesRepositoryProvider.future,
    );
    final profile = await ref.watch(activeProfileProvider.future);
    final clock = ref.watch(reminderClockProvider);
    return SaveReminderPreferences(
      repository: preferences,
      profileId: profile.id,
      clock: clock,
      afterSaved: () => reconcileRemindersAfterChange(ref, profile.id),
    );
  },
);

/// Connects the OS plugin adapter to the profile-scoped reminder ledger.
final notificationSchedulerProvider = FutureProvider<NotificationScheduler>((
  ref,
) async {
  final repository = await ref.watch(
    scheduledReminderRepositoryProvider.future,
  );
  return FlutterLocalNotificationScheduler(
    plugin: FlutterLocalNotificationsPlugin(),
    repository: repository,
  );
});

/// Composes the reminder calculation and OS scheduling ports into one action.
final reconcileRemindersProvider = FutureProvider<ReconcileReminders>((
  ref,
) async {
  final calculateDesired = await ref.watch(
    calculateDesiredRemindersProvider.future,
  );
  final scheduler = await ref.watch(notificationSchedulerProvider.future);
  return ReconcileReminders(
    calculateDesired: calculateDesired,
    scheduler: scheduler,
  );
});
