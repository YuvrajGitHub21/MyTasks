/// Whether Android allows MyTasks to schedule exact, user-facing alarms.
///
/// This is separate from notification permission: Android may allow the app
/// to show notifications while still blocking exact-time alarm scheduling.
enum AlarmPermissionStatus { allowed, notAllowed, unsupported }

/// Application-owned boundary for exact-alarm access.
///
/// The domain/application layers use this contract without importing Android
/// or the Flutter notifications plugin.
abstract interface class AlarmPermissionGateway {
  Future<AlarmPermissionStatus> getStatus();

  /// Opens Android's special access screen after the app explains why it needs
  /// exact alarm timing. The user must grant access in system settings.
  Future<AlarmPermissionStatus> requestAccess();
}
