/// Durable snooze event waiting to be copied from a platform alarm store.
///
/// [payload] contains routing metadata only; it must never contain task text.
final class PendingSnoozeEvent {
  const PendingSnoozeEvent({
    required this.platformAlarmId,
    required this.parentPlatformAlarmId,
    required this.scheduledAtUtc,
    required this.createdAtUtc,
    required this.payload,
  });

  final String platformAlarmId;
  final String parentPlatformAlarmId;
  final DateTime scheduledAtUtc;
  final DateTime createdAtUtc;
  final String payload;
}
