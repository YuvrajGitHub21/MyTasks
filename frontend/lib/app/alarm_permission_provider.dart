import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/flutter_alarm_permission_gateway.dart';
import '../domain/services/alarm_permission_gateway.dart';

/// Provides the Android-specific adapter behind the application contract.
final alarmPermissionGatewayProvider = Provider<AlarmPermissionGateway>(
  (ref) => FlutterAlarmPermissionGateway(
    plugin: FlutterLocalNotificationsPlugin(),
  ),
);

/// Reads exact-alarm access for display in reminder settings.
final alarmPermissionStatusProvider = FutureProvider<AlarmPermissionStatus>(
  (ref) => ref.watch(alarmPermissionGatewayProvider).getStatus(),
);
