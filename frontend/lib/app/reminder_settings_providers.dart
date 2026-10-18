import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/reminder_preferences.dart';
import '../data/local/database_providers.dart';
import '../data/local/reminder_repository_providers.dart';
import 'reminder_use_case_providers.dart';

/// Streams the active profile's saved reminder choices, using product defaults
/// until the user changes a setting for the first time.
final reminderSettingsPreferencesProvider = StreamProvider<ReminderPreferences>(
  (ref) async* {
    final repository = await ref.watch(
      reminderPreferencesRepositoryProvider.future,
    );
    final profile = await ref.watch(activeProfileProvider.future);
    final clock = ref.watch(reminderClockProvider);

    yield* repository
        .watchPreferences(profile.id)
        .map(
          (saved) =>
              saved ??
              ReminderPreferences.defaults(
                profileId: profile.id,
                updatedAtUtc: clock.nowUtc().toUtc(),
              ),
        );
  },
);
