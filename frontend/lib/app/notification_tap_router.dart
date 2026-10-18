import 'dart:convert';

import 'package:flutter/material.dart';

import '../domain/entities/task.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../features/tasks/presentation/task_list_screen.dart';
import '../features/study/presentation/study_screen.dart';

/// Converts privacy-safe notification payloads into app destinations.
class NotificationTapRouter {
  final navigatorKey = GlobalKey<NavigatorState>();
  String? _pendingPayload;

  /// Routes a tap immediately, or holds it until the root Navigator is ready.
  void handlePayload(String payload) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingPayload = payload;
      return;
    }
    final route = _routeFor(payload);
    if (route != null) navigator.push<void>(route);
  }

  /// Flushes a cold-start payload after MaterialApp has mounted its Navigator.
  void onNavigatorReady() {
    final payload = _pendingPayload;
    _pendingPayload = null;
    if (payload != null) handlePayload(payload);
  }

  Route<void>? _routeFor(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
        return null;
      }
      final contentKind = decoded['contentKind'];
      final Widget destination = switch (contentKind) {
        'assignTask' => const TaskFormScreen(),
        'dailySummary' || 'logToday' => const _TodayReminderDestination(),
        'studyBreak' => const StudyScreen(),
        _ => throw const FormatException('Unknown reminder content kind.'),
      };
      return MaterialPageRoute<void>(builder: (_) => destination);
    } catch (error) {
      debugPrint('Ignoring invalid reminder tap payload: $error');
      return null;
    }
  }
}

class _TodayReminderDestination extends StatelessWidget {
  const _TodayReminderDestination();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Today')),
    body: const TaskListScreen(category: TaskCategory.current),
  );
}
