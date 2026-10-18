import 'package:flutter/services.dart';

/// Dart side of the Android alarm platform channel implemented in MainActivity.
///
/// Keeping this adapter in the data layer prevents the domain and application
/// layers from depending on Flutter's MethodChannel API.
final class AndroidTaskAlarmChannel {
  AndroidTaskAlarmChannel({MethodChannel? channel})
    : _channel = channel ?? _defaultChannel;

  static const _defaultChannel = MethodChannel(
    'com.yuvrajpadhy.mytasks/task_alarm',
  );

  final MethodChannel _channel;

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

  Future<List<AndroidPendingSnooze>> getPendingSnoozes() async {
    final values = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'getPendingSnoozes',
    );
    return (values ?? const [])
        .map(AndroidPendingSnooze.fromPlatformMap)
        .toList(growable: false);
  }

  Future<void> acknowledgeSnooze(int id) =>
      _channel.invokeMethod<void>('acknowledgeSnooze', {'id': id});

  void setAlarmOpenedHandler(void Function(String payload) onOpened) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'alarmOpened' && call.arguments is String) {
        onOpened(call.arguments as String);
      }
    });
  }
}

/// Durable native snooze event waiting to be imported into the encrypted DB.
final class AndroidPendingSnooze {
  const AndroidPendingSnooze({
    required this.id,
    required this.parentAlarmId,
    required this.triggerAtMillis,
    required this.createdAtMillis,
    required this.payload,
  });

  factory AndroidPendingSnooze.fromPlatformMap(Map<Object?, Object?> map) =>
      AndroidPendingSnooze(
        id: map['id']! as int,
        parentAlarmId: map['parentAlarmId']! as int,
        triggerAtMillis: map['triggerAtMillis']! as int,
        createdAtMillis: map['createdAtMillis']! as int,
        payload: map['payload']! as String,
      );

  final int id;
  final int parentAlarmId;
  final int triggerAtMillis;
  final int createdAtMillis;
  final String payload;
}
