/// Whether Android allows MyTasks to schedule exact, user-facing alarms.
///
/// This is separate from notification permission: Android may allow the app
/// to show notifications while still blocking exact-time alarm scheduling.
enum AlarmPermissionStatus { allowed, notAllowed, notDetermined, unsupported }

/// Application-owned boundary for exact-alarm access.
///
/// The domain/application layers use this contract without importing Android
/// or the Flutter notifications plugin.
abstract interface class AlarmPermissionGateway {
  Future<AlarmPermissionStatus> getStatus();

  /// Requests platform alarm authorization after an in-app explanation.
  Future<AlarmPermissionStatus> requestAccess();

  /// Opens this app's system settings after authorization has been denied.
  Future<void> openSettings();
}
