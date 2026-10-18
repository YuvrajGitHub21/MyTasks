import 'dart:async';
import 'dart:developer' as developer;

import '../../domain/services/diagnostic_logger.dart';
import 'diagnostic_log_record.dart';
import 'encrypted_diagnostic_log_store.dart';

/// Serialized fire-and-forget logger. Storage failures only reach console.
final class LocalDiagnosticLogger implements DiagnosticLogger {
  static final shared = LocalDiagnosticLogger();

  LocalDiagnosticLogger({
    EncryptedDiagnosticLogStore? store,
    DateTime Function()? clock,
  }) : _store = store ?? EncryptedDiagnosticLogStore(),
       _clock = clock ?? DateTime.now;

  static const _maxQueuedRecords = 200;
  static const _features = {
    'app',
    'database',
    'tasks',
    'progress',
    'reminders',
    'study',
  };
  static const _events = {
    'app.startup.completed',
    'app.flutter_error',
    'app.async_error',
    'database.open.failed',
    'reminder.initialization.failed',
    'task.create.succeeded',
    'task.create.failed',
    'task.update.succeeded',
    'task.update.failed',
    'task.delete.succeeded',
    'task.delete.failed',
    'progress.create.succeeded',
    'progress.create.failed',
    'progress.update.succeeded',
    'progress.update.failed',
    'progress.delete.succeeded',
    'progress.delete.failed',
    'task.complete.succeeded',
    'task.complete.failed',
    'task.reopen.succeeded',
    'task.reopen.failed',
    'reminder.schedule.succeeded',
    'reminder.schedule.failed',
    'reminder.preferences.save.succeeded',
    'reminder.preferences.save.failed',
    'reminder.snooze.import.succeeded',
    'reminder.snooze.import.failed',
    'study.session.start.succeeded',
    'study.session.start.failed',
    'study.break.start.succeeded',
    'study.break.start.failed',
    'study.break.end.succeeded',
    'study.break.end.failed',
    'study.session.stop.succeeded',
    'study.session.stop.failed',
    'study.break_alert.schedule.failed',
    'study.break_alert.cancel.failed',
  };

  final EncryptedDiagnosticLogStore _store;
  final DateTime Function() _clock;
  final List<DiagnosticLogRecord> _pending = [];
  Future<void> _writeQueue = Future<void>.value();
  bool _initialized = false;
  bool _unavailable = false;

  Future<void> initialize() async {
    if (_initialized || _unavailable) return;
    try {
      await _store.initialize();
      _initialized = true;
      for (final record in List<DiagnosticLogRecord>.of(_pending)) {
        _enqueueWrite(record);
      }
      _pending.clear();
    } catch (error, stackTrace) {
      _unavailable = true;
      _pending.clear();
      _consoleFailure(
        'Diagnostic logging could not initialize',
        error,
        stackTrace,
      );
    }
  }

  @override
  void activity(
    String eventName, {
    required String feature,
    Map<String, Object?> attributes = const {},
  }) {
    try {
      _submit(
        DiagnosticLogRecord(
          severity: DiagnosticSeverity.info,
          eventName: _validEvent(eventName),
          feature: _validFeature(feature),
          occurredAtUtc: _clock().toUtc(),
          attributes: attributes,
        ),
      );
    } catch (_) {
      // The diagnostic API is deliberately non-throwing for app operations.
    }
  }

  @override
  void failure(
    String eventName, {
    required String feature,
    required Object error,
    required StackTrace stackTrace,
  }) {
    // Exception messages are intentionally omitted: adapters and platform
    // exceptions sometimes echo task content, SQL values, or filesystem data.
    try {
      final safeStack = _safeStack(stackTrace);
      _submit(
        DiagnosticLogRecord(
          severity: DiagnosticSeverity.error,
          eventName: _validEvent(eventName),
          feature: _validFeature(feature),
          occurredAtUtc: _clock().toUtc(),
          errorType: _safeType(error.runtimeType.toString()),
          safeMessage: 'Exception details omitted for privacy.',
          safeStackTrace: safeStack,
        ),
      );
    } catch (_) {
      // Never recurse or alter application behavior on logger failure.
    }
  }

  Future<void> flush() async {
    if (!_initialized) return;
    await _writeQueue;
  }

  Future<List<String>> readRecent({Duration age = const Duration(days: 7)}) =>
      _store.readRecent(age: age);

  Future<List<String>> readRecentErrors({
    Duration age = const Duration(days: 7),
  }) => _store.readRecentErrors(age: age);

  Future<void> close() => _store.close();

  void _submit(DiagnosticLogRecord record) {
    if (_unavailable) return;
    if (!_initialized) {
      if (_pending.length == _maxQueuedRecords) {
        final lowSeverity = _pending.indexWhere(
          (item) => item.severity.index < DiagnosticSeverity.error.index,
        );
        _pending.removeAt(lowSeverity < 0 ? 0 : lowSeverity);
      }
      _pending.add(record);
      return;
    }
    _enqueueWrite(record);
  }

  void _enqueueWrite(DiagnosticLogRecord record) {
    _writeQueue = _writeQueue.then((_) async {
      try {
        await _store.append(record);
      } catch (error, stackTrace) {
        _consoleFailure('Diagnostic log write failed', error, stackTrace);
      }
    });
  }

  static String _validEvent(String value) =>
      _events.contains(value) ? value : 'diagnostic.event.invalid';

  static String _validFeature(String value) =>
      _features.contains(value) ? value : 'app';

  static String _safeType(String type) =>
      RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,79}$').hasMatch(type)
      ? type
      : 'UnknownException';

  static String _safeStack(StackTrace stackTrace) {
    // Stack frames contain code locations, not exception text. Bound the
    // record and omit path-like or quoted fragments that could carry data.
    final lines = stackTrace.toString().split('\n').take(40).map((line) {
      final trimmed = line.trim();
      if (trimmed.contains('\\Users\\') ||
          trimmed.contains('/Users/') ||
          trimmed.contains('"') ||
          trimmed.contains("'")) {
        return '[redacted frame]';
      }
      return trimmed;
    });
    final result = lines.join('\n');
    return result.length <= 6000 ? result : result.substring(0, 6000);
  }

  static void _consoleFailure(String label, Object error, StackTrace stack) {
    // Do not route logger failures back through this logger.
    developer.log('$label: ${error.runtimeType}', name: 'mytasks.diagnostics');
    developer.log(stack.toString(), name: 'mytasks.diagnostics');
  }
}
