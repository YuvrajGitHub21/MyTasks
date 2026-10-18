import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/services/notification_permission_gateway.dart';
import '../../domain/services/study_break_alert_scheduler.dart';
import '../local/app_database.dart';
import 'flutter_notification_permission_gateway.dart';

/// Schedules a quiet local notification for the end of a study break.
/// A break alert is deliberately separate from Clock-style task alarms.
final class FlutterStudyBreakAlertScheduler
    implements StudyBreakAlertScheduler {
  FlutterStudyBreakAlertScheduler({
    required AppDatabase database,
    required String profileId,
    FlutterLocalNotificationsPlugin? plugin,
    NotificationPermissionGateway? permissionGateway,
  }) : _database = database,
       _profileId = profileId,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _permissionGateway = permissionGateway;

  static const _channelId = 'study_breaks';
  final AppDatabase _database;
  final String _profileId;
  final FlutterLocalNotificationsPlugin _plugin;
  final NotificationPermissionGateway? _permissionGateway;

  @override
  Future<void> schedule({
    required String breakId,
    required DateTime plannedEndAtUtc,
  }) async {
    final permissions =
        _permissionGateway ??
        FlutterNotificationPermissionGateway(plugin: _plugin);
    if (await permissions.getStatus() != NotificationPermissionStatus.enabled) {
      throw StateError('Study break notifications are not enabled.');
    }
    final row =
        await (_database.select(_database.localStudyBreaks)..where(
              (item) =>
                  item.id.equals(breakId) & item.profileId.equals(_profileId),
            ))
            .getSingleOrNull();
    if (row == null || row.endedAtUtc != null) {
      throw StateError('The active study break could not be scheduled.');
    }
    final location = timezone.getLocation('Asia/Kolkata');
    final scheduledDate = timezone.TZDateTime.from(
      plannedEndAtUtc.toUtc(),
      location,
    );
    if (!scheduledDate.isAfter(timezone.TZDateTime.now(location))) return;

    await _plugin.zonedSchedule(
      id: row.notificationId,
      title: 'Break is over',
      body: 'Ready to continue your study session?',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Study breaks',
          channelDescription: 'A reminder when a study break ends.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode({
        'version': 1,
        'contentKind': 'studyBreak',
        'breakId': breakId,
      }),
    );
  }

  @override
  Future<void> cancel(String breakId) async {
    final row =
        await (_database.select(_database.localStudyBreaks)..where(
              (item) =>
                  item.id.equals(breakId) & item.profileId.equals(_profileId),
            ))
            .getSingleOrNull();
    if (row != null) await _plugin.cancel(id: row.notificationId);
  }
}
