import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/entities/reminder_request.dart';
import '../../domain/entities/scheduled_reminder_record.dart';
import '../../domain/repositories/scheduled_reminder_repository.dart';
import '../../domain/services/notification_scheduler.dart';

/// OS notification adapter backed by flutter_local_notifications.
///
/// The encrypted local ledger assigns stable integer IDs. Writing desired
/// records before calling the OS makes a later reconciliation safe to retry.
final class FlutterLocalNotificationScheduler implements NotificationScheduler {
  FlutterLocalNotificationScheduler({
    required FlutterLocalNotificationsPlugin plugin,
    required ScheduledReminderRepository repository,
  }) : _plugin = plugin,
       _repository = repository;

  static const _channelId = 'task_reminders';
  static const _timeZoneName = 'Asia/Kolkata';

  final FlutterLocalNotificationsPlugin _plugin;
  final ScheduledReminderRepository _repository;

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
      await _plugin.cancel(id: record.notificationId);
    }
    if (staleRecords.isNotEmpty) {
      await _repository.deleteRequests(
        profileId: profileId,
        identities: staleRecords
            .map((record) => record.request.identity)
            .toSet(),
      );
    }

    // Reusing the stable ID replaces an existing OS request instead of
    // creating duplicates. Repeating this loop after a crash is safe.
    for (final record in records) {
      await _schedule(record);
    }
  }

  @override
  Future<void> cancelAll(String profileId) async {
    if (profileId.trim().isEmpty) {
      throw ArgumentError.value(profileId, 'profileId', 'Cannot be empty.');
    }

    final records = await _repository.getRequests(profileId);
    for (final record in records) {
      await _plugin.cancel(id: record.notificationId);
    }
    if (records.isNotEmpty) {
      await _repository.deleteRequests(
        profileId: profileId,
        identities: records.map((record) => record.request.identity).toSet(),
      );
    }
  }

  Future<void> _schedule(ScheduledReminderRecord record) async {
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
