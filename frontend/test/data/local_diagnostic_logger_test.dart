import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/data/local/diagnostic_log_record.dart';
import 'package:mytasks/data/local/encrypted_diagnostic_log_store.dart';
import 'package:mytasks/data/local/local_diagnostic_logger.dart';
import 'package:mytasks/domain/services/diagnostic_logger.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('mytasks-diagnostics-');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('stores records encrypted and reads them back in memory', () async {
    final store = _store(directory);
    await store.initialize();
    await store.append(
      _record(event: 'task.create.succeeded', id: 'encrypted-event-id'),
    );
    final clearRecords = await store.readRecent();
    expect(clearRecords.single, contains('task.create.succeeded'));
    await store.close();

    final diskFile = File('${directory.path}/mytasks-diagnostics.sqlite');
    final diskText = String.fromCharCodes(await diskFile.readAsBytes());
    expect(diskText, isNot(contains('task.create.succeeded')));
    expect(diskText, isNot(contains('encrypted-event-id')));
  });

  test('prunes entries older than seven days at startup', () async {
    final store = _store(directory);
    await store.initialize();
    await store.append(
      _record(
        event: 'task.create.succeeded',
        id: 'old-event-id',
        at: DateTime.now().toUtc().subtract(const Duration(days: 8)),
      ),
    );
    await store.append(_record(event: 'study.session.start.succeeded'));
    await store.close();

    final reopened = _store(directory);
    await reopened.initialize();
    final rows = await reopened.readRecent();
    expect(rows, hasLength(1));
    expect(rows.single, contains('study.session.start.succeeded'));
    await reopened.close();
  });

  test('does not replace a missing key when diagnostic data exists', () async {
    final store = _store(directory);
    await store.initialize();
    await store.append(_record(event: 'task.create.succeeded'));
    await store.close();
    final file = File('${directory.path}/mytasks-diagnostics.sqlite');
    final before = await file.readAsBytes();

    final keyless = EncryptedDiagnosticLogStore(
      supportDirectory: () async => directory,
      keyLoader: (exists) async {
        expect(exists, isTrue);
        throw StateError('missing key');
      },
    );
    await expectLater(keyless.initialize(), throwsStateError);
    expect(await file.readAsBytes(), before);
  });

  test('serializes concurrent activity writes and redacts user text', () async {
    final logger = LocalDiagnosticLogger(store: _store(directory));
    await logger.initialize();
    for (var index = 0; index < 60; index++) {
      logger.activity(
        'study.session.marker',
        feature: 'study',
        attributes: {
          'count': index,
          'method': 'percent',
          'topic': 'PRIVATE TASK TOPIC',
        },
      );
    }
    logger.failure(
      'task.create.failed',
      feature: 'tasks',
      error: StateError('PRIVATE TASK TOPIC'),
      stackTrace: StackTrace.current,
    );
    await logger.flush();
    final rows = await logger.readRecent();
    expect(rows, hasLength(61));
    expect(
      rows.every((row) => jsonDecode(row) is Map<String, dynamic>),
      isTrue,
    );
    final allText = rows.join('\n');
    expect(allText, isNot(contains('PRIVATE TASK TOPIC')));
    expect(allText, isNot(contains('"topic"')));
    final errors = await logger.readRecentErrors();
    expect(errors, hasLength(1));
    expect(errors.single, contains('task.create.failed'));
    await logger.close();
  });

  test(
    'a throwing logger cannot change action result or original failure',
    () async {
      const logger = _ThrowingLogger();
      final result = await runDiagnosticOperation<int>(
        logger: logger,
        feature: 'tasks',
        eventName: 'task.create',
        action: () async => 42,
      );
      expect(result, 42);

      final original = StateError('operation failed');
      await expectLater(
        runDiagnosticOperation<void>(
          logger: logger,
          feature: 'tasks',
          eventName: 'task.create',
          action: () async => throw original,
        ),
        throwsA(same(original)),
      );
    },
  );

  test('a full store remains within its two mebibyte database bound', () async {
    final store = _store(directory);
    await store.initialize();
    for (var index = 0; index < 400; index++) {
      await store.append(
        DiagnosticLogRecord(
          severity: DiagnosticSeverity.info,
          eventName: 'test.bounded.event',
          feature: 'tests',
          occurredAtUtc: DateTime.now().toUtc().add(
            Duration(microseconds: index),
          ),
          safeStackTrace: List.filled(6000, 'frame').join('\n'),
          eventId: 'event-$index',
        ),
      );
    }
    await store.append(
      DiagnosticLogRecord(
        severity: DiagnosticSeverity.error,
        eventName: 'test.error.retained',
        feature: 'tests',
        occurredAtUtc: DateTime.now().toUtc(),
        eventId: 'latest-error',
      ),
    );
    expect(await store.readRecentErrors(), hasLength(1));
    expect(
      store.databaseSizeBytes,
      lessThanOrEqualTo(EncryptedDiagnosticLogStore.maxDatabaseBytes),
    );
    await store.close();
  });
}

EncryptedDiagnosticLogStore _store(Directory directory) =>
    EncryptedDiagnosticLogStore(
      supportDirectory: () async => directory,
      keyLoader: (exists) async => '0123456789abcdef' * 4,
    );

DiagnosticLogRecord _record({
  required String event,
  String id = 'event-id',
  DateTime? at,
}) => DiagnosticLogRecord(
  severity: DiagnosticSeverity.info,
  eventName: event,
  feature: 'tasks',
  occurredAtUtc: at ?? DateTime.now().toUtc(),
  eventId: id,
);

final class _ThrowingLogger implements DiagnosticLogger {
  const _ThrowingLogger();

  @override
  void activity(
    String eventName, {
    required String feature,
    Map<String, Object?> attributes = const {},
  }) => throw StateError('logger failed');

  @override
  void failure(
    String eventName, {
    required String feature,
    required Object error,
    required StackTrace stackTrace,
  }) => throw StateError('logger failed');
}
