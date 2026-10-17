import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/reminders/calculate_desired_reminders.dart';
import '../application/reminders/reminder_clock.dart';
import '../application/reminders/save_reminder_preferences.dart';
import '../data/local/database_providers.dart';
import '../data/local/progress_repository_provider.dart';
import '../data/local/reminder_repository_providers.dart';
import '../data/local/task_repository_provider.dart';

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
    );
  },
);
