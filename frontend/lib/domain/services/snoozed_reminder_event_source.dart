import '../entities/pending_snooze_event.dart';

/// Reads durable snooze events from the platform and removes them after import.
abstract interface class SnoozedReminderEventSource {
  Future<List<PendingSnoozeEvent>> getPendingEvents();

  Future<void> acknowledge(String platformAlarmId);
}
