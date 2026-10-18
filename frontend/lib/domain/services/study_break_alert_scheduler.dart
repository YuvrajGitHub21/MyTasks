abstract interface class StudyBreakAlertScheduler {
  /// Schedule or replace a privacy-safe break-end alert for this break.
  Future<void> schedule({
    required String breakId,
    required DateTime plannedEndAtUtc,
  });

  Future<void> cancel(String breakId);
}
