import '../../domain/entities/reminder_preferences.dart';
import '../../domain/entities/task.dart';

/// Converts an IST date and wall-clock reminder time into a UTC instant.
///
/// IST has a fixed UTC+05:30 offset and no daylight-saving transitions. This
/// adapter-level conversion can later move to the timezone package if the
/// product supports additional reminder zones.
abstract final class ReminderScheduleTime {
  static const _istOffset = Duration(hours: 5, minutes: 30);

  static DateTime toUtc(TaskDate date, ReminderTime time) => DateTime.utc(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  ).subtract(_istOffset);

  static TaskDate nextDay(TaskDate date) {
    final next = DateTime.utc(date.year, date.month, date.day + 1);
    return TaskDate.fromDateTime(next);
  }
}
