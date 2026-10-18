import 'package:flutter/foundation.dart';

import '../../domain/services/diagnostic_logger.dart';

/// Connects framework and uncaught platform async failures to local logging.
/// Flutter's normal console presentation is retained for developer builds.
final class DiagnosticErrorCapture {
  DiagnosticErrorCapture._();

  static bool _installed = false;

  static void install(DiagnosticLogger logger) {
    if (_installed) return;
    _installed = true;

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logger.failure(
        'app.flutter_error',
        feature: 'app',
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      logger.failure(
        'app.async_error',
        feature: 'app',
        error: error,
        stackTrace: stackTrace,
      );
      // This mirrors Flutter's documented logging hook behavior: return true
      // after recording, while still printing a diagnostic for run/debug.
      debugPrint('Uncaught asynchronous app error: ${error.runtimeType}');
      debugPrintStack(stackTrace: stackTrace);
      return true;
    };
  }
}
