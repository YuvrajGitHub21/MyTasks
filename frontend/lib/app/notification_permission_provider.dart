import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications/flutter_notification_permission_gateway.dart';
import '../domain/services/notification_permission_gateway.dart';

/// Provides the platform permission adapter to application and presentation
/// code without exposing the plugin directly to those layers.
final notificationPermissionGatewayProvider =
    Provider<NotificationPermissionGateway>(
      (ref) => FlutterNotificationPermissionGateway(
        plugin: FlutterLocalNotificationsPlugin(),
      ),
    );

/// Reads the current OS notification permission for the settings screen.
final notificationPermissionStatusProvider =
    FutureProvider<NotificationPermissionStatus>(
      (ref) => ref.watch(notificationPermissionGatewayProvider).getStatus(),
    );
