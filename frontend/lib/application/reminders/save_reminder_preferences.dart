import '../../domain/entities/reminder_preferences.dart';
import '../../domain/repositories/reminder_preferences_repository.dart';
import 'reminder_clock.dart';

/// Saves preferences only for the active profile and stamps them in UTC.
final class SaveReminderPreferences {
  factory SaveReminderPreferences({
    required ReminderPreferencesRepository repository,
    required String profileId,
    required ReminderClock clock,
  }) => SaveReminderPreferences._(
    repository: repository,
    profileId: profileId,
    clock: clock,
  );

  const SaveReminderPreferences._({
    required this._repository,
    required this._profileId,
    required this._clock,
  });

  final ReminderPreferencesRepository _repository;
  final String _profileId;
  final ReminderClock _clock;

  Future<void> call(ReminderPreferences preferences) async {
    if (preferences.profileId != _profileId) {
      throw ArgumentError.value(
        preferences.profileId,
        'preferences.profileId',
        'Preferences must belong to the active profile.',
      );
    }

    await _repository.savePreferences(
      ReminderPreferences(
        profileId: preferences.profileId,
        enabled: preferences.enabled,
        morningTime: preferences.morningTime,
        middayTime: preferences.middayTime,
        endOfDayTime: preferences.endOfDayTime,
        quietHoursStart: preferences.quietHoursStart,
        quietHoursEnd: preferences.quietHoursEnd,
        soundEnabled: preferences.soundEnabled,
        vibrationEnabled: preferences.vibrationEnabled,
        updatedAtUtc: _clock.nowUtc().toUtc(),
      ),
    );
  }
}
