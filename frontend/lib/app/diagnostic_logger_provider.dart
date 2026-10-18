import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/local_diagnostic_logger.dart';
import '../domain/services/diagnostic_logger.dart';

/// The process-wide, local-only logger composed at the application boundary.
final diagnosticLoggerProvider = Provider<DiagnosticLogger>(
  (ref) => _diagnosticLogger,
);

final _diagnosticLogger = LocalDiagnosticLogger.shared;
