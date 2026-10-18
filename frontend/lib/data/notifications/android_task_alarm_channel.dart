import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/pending_snooze_event.dart';
import '../../domain/services/snoozed_reminder_event_source.dart';
import 'ios_alarm_kit_channel.dart';

/// Dart side of the Android alarm platform channel implemented in MainActivity.
///
/// Keeping this adapter in the data layer prevents the domain and application
/// layers from depending on Flutter's MethodChannel API.
final class AndroidTaskAlarmChannel implements SnoozedReminderEventSource {
  AndroidTaskAlarmChannel({
    MethodChannel? channel,
    IosAlarmKitChannel? iosChannel,
    TargetPlatform? platform,
  }) : _channel = channel ?? _defaultChannel,
       _iosChannel = iosChannel ?? IosAlarmKitChannel(),
       _platform = platform ?? defaultTargetPlatform;

  static const _defaultChannel = MethodChannel(
    'com.yuvrajpadhy.mytasks/task_alarm',
  );

  final MethodChannel _channel;
  final IosAlarmKitChannel _iosChannel;
  final TargetPlatform _platform;

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

  Future<String?> takePendingAlarmPayload() =>
      _channel.invokeMethod<String?>('takePendingAlarmPayload');

  @override
  Future<List<PendingSnoozeEvent>> getPendingEvents() async {
    if (_platform == TargetPlatform.iOS) {
      return _iosChannel.getPendingEvents();
    }
    if (_platform != TargetPlatform.android) return const [];
    final values = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'getPendingSnoozes',
    );
    return (values ?? const []).map(_toPendingEvent).toList(growable: false);
  }

  @override
  Future<void> acknowledge(String platformAlarmId) async {
    if (_platform == TargetPlatform.iOS) {
      await _iosChannel.acknowledge(platformAlarmId);
      return;
    }
    if (_platform != TargetPlatform.android) return;
    final id = int.tryParse(platformAlarmId);
    if (id == null || id <= 0) {
      throw ArgumentError.value(platformAlarmId, 'platformAlarmId');
    }
    await acknowledgeSnooze(id);
  }

  Future<void> acknowledgeSnooze(int id) =>
      _channel.invokeMethod<void>('acknowledgeSnooze', {'id': id});

  PendingSnoozeEvent _toPendingEvent(Map<Object?, Object?> map) =>
      PendingSnoozeEvent(
        platformAlarmId: (map['id']! as int).toString(),
        parentPlatformAlarmId: (map['parentAlarmId']! as int).toString(),
        scheduledAtUtc: DateTime.fromMillisecondsSinceEpoch(
          map['triggerAtMillis']! as int,
          isUtc: true,
        ),
        createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
          map['createdAtMillis']! as int,
          isUtc: true,
        ),
        payload: map['payload']! as String,
      );

  void setAlarmOpenedHandler(void Function(String payload) onOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'alarmOpened' && call.arguments is String) {
        onOpened(call.arguments as String);
      }
    });
  }
}
