import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/services/alarm_permission_gateway.dart';
import 'ios_alarm_kit_channel.dart';

/// Android adapter for the system's exact-alarm special access setting.
final class FlutterAlarmPermissionGateway implements AlarmPermissionGateway {
  FlutterAlarmPermissionGateway({
    required FlutterLocalNotificationsPlugin plugin,
    TargetPlatform? platform,
    IosAlarmKitChannel? iosChannel,
  }) : _plugin = plugin,
       _iosChannel = iosChannel ?? IosAlarmKitChannel(),
       _platform = platform ?? defaultTargetPlatform;

  final FlutterLocalNotificationsPlugin _plugin;
  final IosAlarmKitChannel _iosChannel;
  final TargetPlatform _platform;

  @override
  Future<AlarmPermissionStatus> getStatus() async {
    if (_platform == TargetPlatform.iOS) {
      return _fromIosStatus(await _iosChannel.authorizationStatus());
    }
    if (_platform != TargetPlatform.android) {
      return AlarmPermissionStatus.unsupported;
    }

    final canSchedule = await _androidPlugin?.canScheduleExactNotifications();
    return _fromNullable(canSchedule);
  }

  @override
  Future<AlarmPermissionStatus> requestAccess() async {
    if (_platform == TargetPlatform.iOS) {
      return _fromIosStatus(await _iosChannel.requestAuthorization());
    }
    if (_platform != TargetPlatform.android) {
      return AlarmPermissionStatus.unsupported;
    }

    // Android presents a system settings page for this special access; this
    // call is intentionally made only after an explanatory user action.
    final granted = await _androidPlugin?.requestExactAlarmsPermission();
    return _fromNullable(granted);
  }

  @override
  Future<void> openSettings() async {
    if (_platform == TargetPlatform.iOS) {
      await _iosChannel.openAppSettings();
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  AlarmPermissionStatus _fromNullable(bool? allowed) => switch (allowed) {
    true => AlarmPermissionStatus.allowed,
    false => AlarmPermissionStatus.notAllowed,
    null => AlarmPermissionStatus.unsupported,
  };

  AlarmPermissionStatus _fromIosStatus(String status) => switch (status) {
    'authorized' => AlarmPermissionStatus.allowed,
    'notAllowed' => AlarmPermissionStatus.notAllowed,
    'notDetermined' => AlarmPermissionStatus.notDetermined,
    _ => AlarmPermissionStatus.unsupported,
  };
}
