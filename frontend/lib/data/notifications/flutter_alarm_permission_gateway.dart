import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/services/alarm_permission_gateway.dart';

/// Android adapter for the system's exact-alarm special access setting.
final class FlutterAlarmPermissionGateway implements AlarmPermissionGateway {
  FlutterAlarmPermissionGateway({
    required FlutterLocalNotificationsPlugin plugin,
    TargetPlatform? platform,
  }) : _plugin = plugin,
       _platform = platform ?? defaultTargetPlatform;

  final FlutterLocalNotificationsPlugin _plugin;
  final TargetPlatform _platform;

  @override
  Future<AlarmPermissionStatus> getStatus() async {
    if (_platform != TargetPlatform.android) {
      return AlarmPermissionStatus.unsupported;
    }

    final canSchedule = await _androidPlugin?.canScheduleExactNotifications();
    return _fromNullable(canSchedule);
  }

  @override
  Future<AlarmPermissionStatus> requestAccess() async {
    if (_platform != TargetPlatform.android) {
      return AlarmPermissionStatus.unsupported;
    }

    // Android presents a system settings page for this special access; this
    // call is intentionally made only after an explanatory user action.
    final granted = await _androidPlugin?.requestExactAlarmsPermission();
    return _fromNullable(granted);
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  AlarmPermissionStatus _fromNullable(bool? allowed) => switch (allowed) {
    true => AlarmPermissionStatus.allowed,
    false => AlarmPermissionStatus.notAllowed,
    null => AlarmPermissionStatus.unsupported,
  };
}
