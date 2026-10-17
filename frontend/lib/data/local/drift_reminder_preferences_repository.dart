import 'package:drift/drift.dart';

import '../../domain/entities/reminder_preferences.dart' as domain;
import '../../domain/repositories/reminder_preferences_repository.dart';
import 'app_database.dart';

/// Drift adapter for per-profile reminder preferences.
final class DriftReminderPreferencesRepository
    implements ReminderPreferencesRepository {
  DriftReminderPreferencesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<domain.ReminderPreferences?> getPreferences(String profileId) async {
    final row =
        await (_database.select(_database.reminderPreferences)
              ..where((preference) => preference.profileId.equals(profileId)))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Stream<domain.ReminderPreferences?> watchPreferences(String profileId) =>
      (_database.select(_database.reminderPreferences)
            ..where((preference) => preference.profileId.equals(profileId)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : _toDomain(row));

  @override
  Future<void> savePreferences(domain.ReminderPreferences preferences) async {
    if (preferences.profileId.trim().isEmpty) {
      throw ArgumentError.value(
        preferences.profileId,
        'preferences.profileId',
        'Cannot be empty.',
      );
    }

    await _database
        .into(_database.reminderPreferences)
        .insertOnConflictUpdate(
          ReminderPreferencesCompanion(
            profileId: Value(preferences.profileId),
            enabled: Value(preferences.enabled),
            morningTimeMinutes: Value(
              preferences.morningTime.minutesAfterMidnight,
            ),
            middayTimeMinutes: Value(
              preferences.middayTime.minutesAfterMidnight,
            ),
            endOfDayTimeMinutes: Value(
              preferences.endOfDayTime.minutesAfterMidnight,
            ),
            quietHoursStartMinutes: Value(
              preferences.quietHoursStart?.minutesAfterMidnight,
            ),
            quietHoursEndMinutes: Value(
              preferences.quietHoursEnd?.minutesAfterMidnight,
            ),
            soundEnabled: Value(preferences.soundEnabled),
            vibrationEnabled: Value(preferences.vibrationEnabled),
            updatedAtUtc: Value(preferences.updatedAtUtc.toUtc()),
          ),
        );
  }

  domain.ReminderPreferences _toDomain(ReminderPreferenceRecord row) =>
      domain.ReminderPreferences(
        profileId: row.profileId,
        enabled: row.enabled,
        morningTime: domain.ReminderTime(row.morningTimeMinutes),
        middayTime: domain.ReminderTime(row.middayTimeMinutes),
        endOfDayTime: domain.ReminderTime(row.endOfDayTimeMinutes),
        quietHoursStart: row.quietHoursStartMinutes == null
            ? null
            : domain.ReminderTime(row.quietHoursStartMinutes!),
        quietHoursEnd: row.quietHoursEndMinutes == null
            ? null
            : domain.ReminderTime(row.quietHoursEndMinutes!),
        soundEnabled: row.soundEnabled,
        vibrationEnabled: row.vibrationEnabled,
        updatedAtUtc: row.updatedAtUtc.toUtc(),
      );
}
