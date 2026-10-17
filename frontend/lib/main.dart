import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/my_tasks_app.dart';
import 'data/notifications/local_notification_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LocalNotificationInitializer().initialize();
  } catch (error, stackTrace) {
    // Reminder setup must not prevent the user's task list from opening.
    debugPrint('Reminder setup failed; task management remains available: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    const ProviderScope(
      child: MyTasksApp(),
    ),
  );
}
