import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/entities/reminder_preferences.dart';
import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/scheduled_reminder_record.dart';
import '../../domain/repositories/reminder_preferences_repository.dart';
import '../../domain/repositories/scheduled_reminder_repository.dart';
import '../../domain/services/alarm_permission_gateway.dart';
import '../../domain/services/notification_scheduler.dart';
import 'android_task_alarm_channel.dart';

/// OS notification adapter backed by flutter_local_notifications.
///
/// The encrypted local ledger assigns stable integer IDs. Writing desired
/// records before calling the OS makes a later reconciliation safe to retry.
final class FlutterLocalNotificationScheduler implements NotificationScheduler {
  FlutterLocalNotificationScheduler({
    required this._plugin,
    required this._repository,
    required this._preferencesRepository,
    required this._alarmPermissionGateway,
    AndroidTaskAlarmChannel? alarmChannel,
    TargetPlatform? platform,
  }) : _alarmChannel = alarmChannel ?? AndroidTaskAlarmChannel(),
       _platform = platform ?? defaultTargetPlatform;

  static const _channelId = 'task_reminders';
  static const _timeZoneName = 'Asia/Kolkata';

  final FlutterLocalNotificationsPlugin _plugin;
  final ScheduledReminderRepository _repository;
  final ReminderPreferencesRepository _preferencesRepository;
  final AlarmPermissionGateway _alarmPermissionGateway;
  final AndroidTaskAlarmChannel _alarmChannel;
  final TargetPlatform _platform;

  @override
  Future<void> replaceScheduledRequests(
    String profileId,
    List<ReminderRequest> requests,
  ) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'Cannot be empty.');
    }
    if (requests.any((request) => request.profileId != profileId)) {
      throw StateError('A reminder cannot be scheduled for another profile.');
    }
    final desiredIdentities = requests
        .map((request) => request.identity)
        .toSet();
    if (desiredIdentities.length != requests.length) {
      throw ArgumentError('Desired reminders must have unique identities.');
    }

    final previouslySaved = await _repository.getRequests(profileId);
    final records = await _repository.upsertDesiredRequests(
      profileId: profileId,
      requests: requests,
      updatedAtUtc: DateTime.now().toUtc(),
    );

    // Cancel stale OS requests before deleting their ledger rows. If a cancel
    // fails, the row remains so the next reconciliation can retry it.
    final staleRecords = previouslySaved
        .where((record) => !desiredIdentities.contains(record.request.identity))
        .toList(growable: false);
    for (final record in staleRecords) {
      await _cancelOnPlatforms(record.notificationId);
    }
    if (staleRecords.isNotEmpty) {
      await _repository.deleteRequests(
        profileId: profileId,
        identities: staleRecords
            .map((record) => record.request.identity)
            .toSet(),
      );
    }

    final preferences =
        await _preferencesRepository.getPreferences(profileId) ??
        ReminderPreferences.defaults(
          profileId: profileId,
          updatedAtUtc: DateTime.now().toUtc(),
        );
    final hasActionableReminders = records.any(
      (record) =>
          record.request.contentKind != ReminderContentKind.dailySummary,
    );
    final exactAlarmAllowed =
        _platform == TargetPlatform.android &&
        hasActionableReminders &&
        await _alarmPermissionGateway.getStatus() ==
            AlarmPermissionStatus.allowed;

    // Stable IDs replace previous requests, making reconciliation safe to retry.
    for (final record in records) {
      final request = record.request;
      final isActionable =
          request.contentKind != ReminderContentKind.dailySummary;
      final shouldUseAlarm = isActionable && exactAlarmAllowed;
      final canUseStandardNotification =
          !isActionable || preferences.allowStandardNotificationFallback;

      if (shouldUseAlarm) {
        await _plugin.cancel(id: record.notificationId);
        try {
          await _scheduleAlarm(record);
        } catch (_) {
          // Permission can be revoked between the status check and scheduling.
          // A regular notification is used only after the user's explicit opt-in.
          await _alarmChannel.cancel(record.notificationId);
          if (!preferences.allowStandardNotificationFallback) rethrow;
          await _scheduleNotification(record);
        }
      } else if (canUseStandardNotification) {
        if (_platform == TargetPlatform.android) {
          await _alarmChannel.cancel(record.notificationId);
        }
        await _scheduleNotification(record);
      } else {
        await _cancelOnPlatforms(record.notificationId);
      }
    }
  }

  @override
  Future<void> cancelAll(String profileId) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'Cannot be empty.');
    }

    final records = await _repository.getRequests(profileId);
    for (final record in records) {
      await _cancelOnPlatforms(record.notificationId);
    }
    if (records.isNotEmpty) {
      await _repository.deleteRequests(
        profileId: profileId,
        identities: records.map((record) => record.request.identity).toSet(),
      );
    }
  }

  Future<void> _scheduleNotification(ScheduledReminderRecord record) async {
    final request = record.request;
    final content = _contentFor(request);
    final scheduledDate = timezone.TZDateTime.from(
      request.scheduledAtUtc,
      timezone.getLocation(_timeZoneName),
    );

    await _plugin.zonedSchedule(
      id: record.notificationId,
      title: content.title,
      body: content.body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Task reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Payload contains only routing metadata. Never include task text.
      payload: jsonEncode({
        'version': 1,
        'contentKind': request.contentKind.name,
        'identity': request.identity,
      }),
    );
  }

  Future<void> _scheduleAlarm(ScheduledReminderRecord record) async {
    final request = record.request;
    final content = _contentFor(request);
    await _alarmChannel.schedule(
      id: record.notificationId,
      scheduledAtUtc: request.scheduledAtUtc,
      title: content.title,
      body: content.body,
      payload: _payloadFor(request),
    );
  }

  Future<void> _cancelOnPlatforms(int id) async {
    await _plugin.cancel(id: id);
    if (_platform == TargetPlatform.android) {
      await _alarmChannel.cancel(id);
    }
  }

  String _payloadFor(ReminderRequest request) => jsonEncode({
    'version': 1,
    'contentKind': request.contentKind.name,
    'identity': request.identity,
  });

  _ReminderContent _contentFor(ReminderRequest request) =>
      switch (request.contentKind) {
        ReminderContentKind.dailySummary => _ReminderContent(
          'Today’s plan',
          '${request.taskCount ?? 0} tasks are planned for today.',
        ),
        ReminderContentKind.assignTask => _ReminderContent(
          'Plan today’s work',
          'No task is assigned for today. Take a moment to plan your day.',
        ),
        ReminderContentKind.logToday => _ReminderContent(
          'Log today’s progress',
          '${request.taskCount ?? 0} tasks may need a progress update today.',
        ),
      };
}

final class _ReminderContent {
  const _ReminderContent(this.title, this.body);

  final String title;
  final String body;
}
