import 'dart:async';

import 'package:flutter/material.dart';

import '../data/notifications/android_task_alarm_channel.dart';
import '../data/notifications/local_notification_initializer.dart';
import 'app_shell.dart';
import 'notification_tap_router.dart';
import 'reminder_reconciliation_observer.dart';

class MyTasksApp extends StatefulWidget {
  const MyTasksApp({super.key});

  @override
  State<MyTasksApp> createState() => _MyTasksAppState();
}

class _MyTasksAppState extends State<MyTasksApp> {
  final _notificationTapRouter = NotificationTapRouter();
  final _alarmChannel = AndroidTaskAlarmChannel();
  StreamSubscription<String>? _tapSubscription;

  static const _brandGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _tapSubscription = LocalNotificationInitializer.tapPayloads.listen(
      _notificationTapRouter.handlePayload,
    );
    _alarmChannel.setAlarmOpenedHandler(_notificationTapRouter.handlePayload);
    unawaited(_takePendingAlarmPayload());
    final launchPayload = LocalNotificationInitializer.takeLaunchPayload();
    if (launchPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _notificationTapRouter.handlePayload(launchPayload);
        _notificationTapRouter.onNavigatorReady();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _notificationTapRouter.onNavigatorReady();
      });
    }
  }

  Future<void> _takePendingAlarmPayload() async {
    try {
      final payload = await _alarmChannel.takePendingAlarmPayload();
      if (payload != null) _notificationTapRouter.handlePayload(payload);
    } catch (_) {
      // iOS has a separate AlarmKit adapter; Android-only channel absence must
      // not prevent the task application from starting on other platforms.
    }
  }

  @override
  void dispose() {
    unawaited(_tapSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _notificationTapRouter.navigatorKey,
      title: 'MyTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandGreen,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandGreen,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ReminderReconciliationObserver(child: AppShell()),
    );
  }
}
