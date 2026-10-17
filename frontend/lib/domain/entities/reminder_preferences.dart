/// A wall-clock time represented as minutes after midnight.
///
/// Reminder times are interpreted in India Standard Time by the application
/// layer; this domain value intentionally has no dependency on time-zone APIs.
final class ReminderTime implements Comparable<ReminderTime> {
  ReminderTime(this.minutesAfterMidnight) {
    if (minutesAfterMidnight < 0 || minutesAfterMidnight >= 24 * 60) {
      throw ArgumentError.value(
        minutesAfterMidnight,
        'minutesAfterMidnight',
        'Must be from 0 through 1439.',
      );
    }
  }

  final int minutesAfterMidnight;

  int get hour => minutesAfterMidnight ~/ 60;
  int get minute => minutesAfterMidnight % 60;

  @override
  int compareTo(ReminderTime other) =>
      minutesAfterMidnight.compareTo(other.minutesAfterMidnight);

  @override
  bool operator ==(Object other) =>
      other is ReminderTime &&
      other.minutesAfterMidnight == minutesAfterMidnight;

  @override
  int get hashCode => minutesAfterMidnight.hashCode;

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// Per-profile choices for local reminders.
final class ReminderPreferences {
  const ReminderPreferences({
    required this.profileId,
    required this.enabled,
    required this.morningTime,
    required this.middayTime,
    required this.endOfDayTime,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.updatedAtUtc,
  }) : assert((quietHoursStart == null) == (quietHoursEnd == null));

  factory ReminderPreferences.defaults({
    required String profileId,
    required DateTime updatedAtUtc,
  }) => ReminderPreferences(
    profileId: profileId,
    enabled: true,
    morningTime: ReminderTime(9 * 60),
    middayTime: ReminderTime(12 * 60),
    endOfDayTime: ReminderTime(22 * 60),
    soundEnabled: true,
    vibrationEnabled: true,
    updatedAtUtc: updatedAtUtc.toUtc(),
  );

  final String profileId;
  final bool enabled;
  final ReminderTime morningTime;
  final ReminderTime middayTime;
  final ReminderTime endOfDayTime;
  final ReminderTime? quietHoursStart;
  final ReminderTime? quietHoursEnd;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime updatedAtUtc;

  bool get quietHoursEnabled => quietHoursStart != null;
}
