import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/services/notification_permission_gateway.dart';

/// Reads and requests notification permission through the platform plugin.
final class FlutterNotificationPermissionGateway
    implements NotificationPermissionGateway {
  FlutterNotificationPermissionGateway({
    required FlutterLocalNotificationsPlugin plugin,
    TargetPlatform? platform,
  }) : _plugin = plugin,
       _platform = platform ?? defaultTargetPlatform;

  final FlutterLocalNotificationsPlugin _plugin;
  final TargetPlatform _platform;

  @override
  Future<NotificationPermissionStatus> getStatus() async {
    switch (_platform) {
      case TargetPlatform.android:
        final enabled = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled();
        return _fromNullable(enabled);
      case TargetPlatform.iOS:
        final options = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions();
        if (options == null) return NotificationPermissionStatus.unavailable;
        return options.isEnabled || options.isProvisionalEnabled
            ? NotificationPermissionStatus.enabled
            : NotificationPermissionStatus.disabled;
      default:
        return NotificationPermissionStatus.unavailable;
    }
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    switch (_platform) {
      case TargetPlatform.android:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
        return _fromNullable(granted);
      case TargetPlatform.iOS:
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return _fromNullable(granted);
      default:
        return NotificationPermissionStatus.unavailable;
    }
  }

  @override
  Future<bool> openSystemSettings() async =>
      await _plugin.openAppNotificationSettings() ?? false;

  NotificationPermissionStatus _fromNullable(bool? enabled) =>
      switch (enabled) {
        true => NotificationPermissionStatus.enabled,
        false => NotificationPermissionStatus.disabled,
        null => NotificationPermissionStatus.unavailable,
      };
}
