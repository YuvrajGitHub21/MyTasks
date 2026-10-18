import '../../domain/entities/reminder_preferences.dart';
import '../../domain/repositories/reminder_preferences_repository.dart';
import '../../domain/services/diagnostic_logger.dart';
import 'reminder_clock.dart';

/// Saves preferences only for the active profile and stamps them in UTC.
final class SaveReminderPreferences {
  factory SaveReminderPreferences({
    required ReminderPreferencesRepository repository,
    required String profileId,
    required ReminderClock clock,
    Future<void> Function()? afterSaved,
    DiagnosticLogger logger = const NoopDiagnosticLogger(),
  }) => SaveReminderPreferences._(
    repository: repository,
    profileId: profileId,
    clock: clock,
    afterSaved: afterSaved,
    logger: logger,
  );

  const SaveReminderPreferences._({
    required this._repository,
    required this._profileId,
    required this._clock,
    required this._afterSaved,
    required this._logger,
  });

  final ReminderPreferencesRepository _repository;
  final String _profileId;
  final ReminderClock _clock;
  final Future<void> Function()? _afterSaved;
  final DiagnosticLogger _logger;

  Future<void> call(ReminderPreferences preferences) => runDiagnosticOperation(
    logger: _logger,
    feature: 'reminders',
    eventName: 'reminder.preferences.save',
    action: () async {
      if (preferences.profileId != _profileId) {
        throw ArgumentError.value(
          preferences.profileId,
          'preferences.profileId',
          'Preferences must belong to the active profile.',
        );
      }
      if (preferences.quietHoursStart != preferences.quietHoursEnd &&
          (preferences.quietHoursStart == null ||
              preferences.quietHoursEnd == null)) {
        throw ArgumentError(
          'Quiet-hours start and end must both be set or both be disabled.',
        );
      }
      if (preferences.quietHoursStart != null &&
          preferences.quietHoursStart == preferences.quietHoursEnd) {
        throw ArgumentError('Quiet-hours start and end must differ.');
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
          allowStandardNotificationFallback:
              preferences.allowStandardNotificationFallback,
          soundEnabled: preferences.soundEnabled,
          vibrationEnabled: preferences.vibrationEnabled,
          updatedAtUtc: _clock.nowUtc().toUtc(),
        ),
      );
      await _afterSaved?.call();
    },
  );
}
