/// Small application-facing port for privacy-safe diagnostic activity.
///
/// Methods are intentionally fire-and-forget. Implementations must isolate
/// storage failures so diagnostics can never change a business operation.
abstract interface class DiagnosticLogger {
  void activity(
    String eventName, {
    required String feature,
    Map<String, Object?> attributes = const {},
  });

  void failure(
    String eventName, {
    required String feature,
    required Object error,
    required StackTrace stackTrace,
  });
}

/// Runs one meaningful operation and records success/failure without making
/// the operation depend on a working diagnostic store.
Future<T> runDiagnosticOperation<T>({
  required DiagnosticLogger logger,
  required String feature,
  required String eventName,
  required Future<T> Function() action,
  Map<String, Object?> attributes = const {},
}) async {
  late T result;
  try {
    result = await action();
  } catch (error, stackTrace) {
    try {
      logger.failure(
        '$eventName.failed',
        feature: feature,
        error: error,
        stackTrace: stackTrace,
      );
    } catch (_) {
      // Diagnostics are never allowed to replace the actual operation error.
    }
    rethrow;
  }
  try {
    logger.activity(
      '$eventName.succeeded',
      feature: feature,
      attributes: attributes,
    );
  } catch (_) {
    // Best effort: a logger failure must not turn success into a failure.
  }
  return result;
}

/// Allows use cases to run without diagnostics in isolated unit tests.
final class NoopDiagnosticLogger implements DiagnosticLogger {
  const NoopDiagnosticLogger();

  @override
  void activity(
    String eventName, {
    required String feature,
    Map<String, Object?> attributes = const {},
  }) {}

  @override
  void failure(
    String eventName, {
    required String feature,
    required Object error,
    required StackTrace stackTrace,
  }) {}
}
