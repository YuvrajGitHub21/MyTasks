/// A calendar date without a time or time zone.
/// Task dates are interpreted in Asia/Kolkata and stored as `YYYY-MM-DD`.
final class TaskDate implements Comparable<TaskDate> {
  const TaskDate._(this.year, this.month, this.day);

  factory TaskDate(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    if (normalized.year != year ||
        normalized.month != month ||
        normalized.day != day) {
      throw ArgumentError(
        'The supplied values do not form a valid calendar date.',
      );
    }
    return TaskDate._(year, month, day);
  }

  /// Keeps the calendar components selected by a date picker.
  factory TaskDate.fromDateTime(DateTime value) =>
      TaskDate(value.year, value.month, value.day);

  /// Gets today's calendar date at the fixed India Standard Time offset.
  factory TaskDate.todayInIst([DateTime? instant]) {
    final utcInstant = (instant ?? DateTime.now()).toUtc();
    final istInstant = utcInstant.add(const Duration(hours: 5, minutes: 30));
    return TaskDate(istInstant.year, istInstant.month, istInstant.day);
  }

  /// Reads the stable `YYYY-MM-DD` database representation.
  factory TaskDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Expected a date in YYYY-MM-DD format.', value);
    }
    try {
      return TaskDate(
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
    } on ArgumentError {
      throw FormatException(
        'The supplied value is not a valid calendar date.',
        value,
      );
    }
  }

  final int year;
  final int month;
  final int day;

  String toStorageString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(TaskDate other) {
    final yearOrder = year.compareTo(other.year);
    if (yearOrder != 0) return yearOrder;
    final monthOrder = month.compareTo(other.month);
    if (monthOrder != 0) return monthOrder;
    return day.compareTo(other.day);
  }

  bool operator <(TaskDate other) => compareTo(other) < 0;
  bool operator <=(TaskDate other) => compareTo(other) <= 0;
  bool operator >(TaskDate other) => compareTo(other) > 0;
  bool operator >=(TaskDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is TaskDate &&
      year == other.year &&
      month == other.month &&
      day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toStorageString();
}

enum TaskStatus { open, completed }

enum TaskCategory { current, scheduled, overdue, completed }

enum EffortBand { level1, level2, level3, level4, level5 }

/// Current task fields. Stable IDs allow later offline synchronization.
final class Task {
  const Task({
    required this.id,
    required this.profileId,
    required this.topic,
    this.subtopic,
    this.description,
    required this.startDate,
    required this.plannedEndDate,
    this.maximumEndDate,
    required this.effortHundredths,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final String topic;
  final String? subtopic;
  final String? description;
  final TaskDate startDate;
  final TaskDate plannedEndDate;
  final TaskDate? maximumEndDate;

  /// Hundredths of an hour; 3.50 hours is stored as 350.
  final int effortHundredths;

  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;
}
