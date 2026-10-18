import 'package:flutter/services.dart';

import '../../domain/entities/pending_snooze_event.dart';
import '../../domain/services/snoozed_reminder_event_source.dart';

/// Dart bridge to the native AlarmKit adapter in AppDelegate.swift.
final class IosAlarmKitChannel implements SnoozedReminderEventSource {
  IosAlarmKitChannel({MethodChannel? channel})
    : _channel = channel ?? _defaultChannel;

  static const _defaultChannel = MethodChannel(
    'com.yuvrajpadhy.mytasks/alarm_kit',
  );

  final MethodChannel _channel;

  Future<String> authorizationStatus() async =>
      await _channel.invokeMethod<String>('authorizationStatus') ??
      'unsupported';

  Future<String> requestAuthorization() async =>
      await _channel.invokeMethod<String>('requestAuthorization') ??
      'unsupported';

  Future<void> openAppSettings() =>
      _channel.invokeMethod<void>('openAppSettings');

  Future<String?> takePendingAlarmPayload() =>
      _channel.invokeMethod<String?>('takePendingAlarmPayload');

  @override
  Future<List<PendingSnoozeEvent>> getPendingEvents() async {
    final rows = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'getPendingSnoozes',
    );
    return (rows ?? const [])
        .map((row) {
          final createdAt = row['createdAtMillis']! as int;
          return PendingSnoozeEvent(
            platformAlarmId: 'ios:${row['id']! as String}',
            parentPlatformAlarmId: (row['parentAlarmId']! as int).toString(),
            scheduledAtUtc: DateTime.fromMillisecondsSinceEpoch(
              row['triggerAtMillis']! as int,
              isUtc: true,
            ),
            createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
              createdAt,
              isUtc: true,
            ),
            payload: row['payload']! as String,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<void> acknowledge(String platformAlarmId) async {
    if (!platformAlarmId.startsWith('ios:')) {
      throw ArgumentError.value(platformAlarmId, 'platformAlarmId');
    }
    await _channel.invokeMethod<void>('acknowledgeSnooze', {
      'id': platformAlarmId.substring(4),
    });
  }

  Future<void> schedule({
    required int id,
    required DateTime scheduledAtUtc,
    required String title,
    required String body,
    required String payload,
  }) => _channel.invokeMethod<void>('scheduleAlarm', {
    'id': id,
    'triggerAtMillis': scheduledAtUtc.toUtc().millisecondsSinceEpoch,
    'title': title,
    'body': body,
    'payload': payload,
  });

  Future<void> cancel(int id) =>
      _channel.invokeMethod<void>('cancelAlarm', {'id': id});
}
