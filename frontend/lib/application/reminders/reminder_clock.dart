/// Application-owned clock so reminder calculations can use a consistent,
/// injectable instant instead of reading the device time in multiple places.
abstract interface class ReminderClock {
  DateTime nowUtc();
}

final class SystemReminderClock implements ReminderClock {
  const SystemReminderClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
