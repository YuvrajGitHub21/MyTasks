import '../../../domain/entities/task.dart';

/// Converts date-only task values to concise user-facing labels.
String formatTaskDate(TaskDate date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Presents persisted UTC instants in the product's fixed Asia/Kolkata zone.
String formatInstantInIst(DateTime instant) {
  final ist = instant.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  final period = ist.hour < 12 ? 'AM' : 'PM';
  return '${formatTaskDate(TaskDate(ist.year, ist.month, ist.day))} · '
      '$hour:${ist.minute.toString().padLeft(2, '0')} $period';
}
