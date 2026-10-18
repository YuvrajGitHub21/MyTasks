/// Cross-platform notification permission state that the app can reliably
/// display without assuming whether permission was previously requested.
enum NotificationPermissionStatus { enabled, disabled, unavailable }

/// Application-owned boundary for checking and requesting OS notification
/// permission. Platform plugin details stay in the data layer.
abstract interface class NotificationPermissionGateway {
  Future<NotificationPermissionStatus> getStatus();

  /// Shows the operating-system prompt when supported and returns the
  /// resulting state. The caller must first explain why reminders need access.
  Future<NotificationPermissionStatus> requestPermission();

  /// Opens this app's notification settings, if the platform supports it.
  Future<bool> openSystemSettings();
}
