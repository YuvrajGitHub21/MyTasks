import 'dart:convert';

import 'package:uuid/uuid.dart';

enum DiagnosticSeverity { debug, info, warning, error, fatal }

/// A structured, privacy-filtered record before database encryption.
final class DiagnosticLogRecord {
  DiagnosticLogRecord({
    required this.severity,
    required this.eventName,
    required this.feature,
    required this.occurredAtUtc,
    Map<String, Object?> attributes = const {},
    this.errorType,
    this.safeMessage,
    this.safeStackTrace,
    String? eventId,
  }) : eventId = eventId ?? const Uuid().v4(),
       attributes = _safeAttributes(attributes);

  final String eventId;
  final DiagnosticSeverity severity;
  final String eventName;
  final String feature;
  final DateTime occurredAtUtc;
  final Map<String, Object?> attributes;
  final String? errorType;
  final String? safeMessage;
  final String? safeStackTrace;

  String toJson() => jsonEncode({
    'schemaVersion': 1,
    'eventId': eventId,
    'timestampUtc': occurredAtUtc.toUtc().toIso8601String(),
    'severity': severity.name,
    'event': eventName,
    'feature': feature,
    if (attributes.isNotEmpty) 'attributes': attributes,
    if (errorType != null) 'errorType': errorType,
    if (safeMessage != null) 'message': safeMessage,
    if (safeStackTrace != null) 'stackTrace': safeStackTrace,
  });

  static Map<String, Object?> _safeAttributes(Map<String, Object?> source) {
    // Allow only stable diagnostic fields. Free-form text and identifiers are
    // deliberately excluded before the record reaches encryption/storage.
    const allowed = {
      'count',
      'durationMinutes',
      'breakMinutes',
      'enabled',
      'outcome',
      'status',
      'method',
    };
    const safeStrings = {
      'outcome': {'success', 'failed', 'scheduled', 'cancelled', 'denied'},
      'status': {'open', 'completed', 'running', 'onBreak', 'stopped'},
      'method': {'percent', 'units', 'note'},
    };
    final result = <String, Object?>{};
    for (final entry in source.entries) {
      if (!allowed.contains(entry.key)) continue;
      final value = entry.value;
      if (value is bool) {
        result[entry.key] = value;
      } else if (value is int && value >= 0 && value <= 1000000) {
        result[entry.key] = value;
      } else if (value is String &&
          safeStrings[entry.key]?.contains(value) == true) {
        result[entry.key] = value;
      }
    }
    return Map.unmodifiable(result);
  }
}
