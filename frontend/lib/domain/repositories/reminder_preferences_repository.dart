import '../entities/reminder_preferences.dart';

/// Per-profile storage boundary for reminder choices.
abstract interface class ReminderPreferencesRepository {
  Future<ReminderPreferences?> getPreferences(String profileId);

  Stream<ReminderPreferences?> watchPreferences(String profileId);

  Future<void> savePreferences(ReminderPreferences preferences);
}
