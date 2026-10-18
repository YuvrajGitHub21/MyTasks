import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'app/my_tasks_app.dart';
import 'data/local/diagnostic_error_capture.dart';
import 'data/local/local_diagnostic_logger.dart';
import 'data/notifications/local_notification_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final diagnosticLogger = LocalDiagnosticLogger.shared;
  // Install hooks before initializing storage or the notification plugin so
  // startup failures can be recorded. Logging itself is best-effort.
  DiagnosticErrorCapture.install(diagnosticLogger);
  await diagnosticLogger.initialize();
  diagnosticLogger.activity('app.startup.completed', feature: 'app');

  LicenseRegistry.addLicense(() async* {
    final licenseText = await rootBundle.loadString(
      'assets/fonts/OFL-NunitoSans.txt',
    );
    yield LicenseEntryWithLineBreaks(['Nunito Sans'], licenseText);
  });

  try {
    await LocalNotificationInitializer().initialize();
  } catch (error, stackTrace) {
    // Reminder setup must not prevent the user's task list from opening.
    debugPrint(
      'Reminder setup failed; task management remains available: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
    diagnosticLogger.failure(
      'reminder.initialization.failed',
      feature: 'reminders',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(const ProviderScope(child: MyTasksApp()));
}
