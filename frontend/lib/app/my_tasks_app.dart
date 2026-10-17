import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'reminder_reconciliation_observer.dart';

class MyTasksApp extends StatelessWidget {
  const MyTasksApp({super.key});

  static const _brandGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
