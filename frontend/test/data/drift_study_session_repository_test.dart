import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/data/local/app_database.dart';
import 'package:mytasks/data/local/drift_study_session_repository.dart';
import 'package:mytasks/data/local/local_profile_store.dart';
import 'package:mytasks/data/local/drift_task_repository.dart';
import 'package:mytasks/domain/entities/study_session.dart';
import 'package:mytasks/domain/entities/task.dart';

void main() {
  // Tests deliberately open independent in-memory and migration-fixture DBs.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase database;
  late DriftStudySessionRepository repository;
  late String profileId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final profile = await LocalProfileStore(database).getOrCreateGuestProfile();
    profileId = profile.id;
    repository = DriftStudySessionRepository(database, profileId);
  });

  tearDown(() => database.close());

  test('persists running, break, resume, and stop transitions', () async {
    final start = DateTime.utc(2026, 10, 18, 3);
    final created = await repository.startSession(
      id: 'session-1',
      profileId: profileId,
      taskId: null,
      nowUtc: start,
    );
    expect(created.session.status, StudySessionStatus.running);
    expect(
      created.session.focusedSecondsAt(start.add(const Duration(seconds: 40))),
      40,
    );

    await expectLater(
      repository.startSession(
        id: 'session-2',
        profileId: profileId,
        taskId: null,
        nowUtc: start.add(const Duration(minutes: 1)),
      ),
      throwsA(isA<StateError>()),
    );

    final breakDetail = await repository.takeBreak(
      sessionId: 'session-1',
      profileId: profileId,
      breakId: 'break-1',
      durationMinutes: 10,
      nowUtc: start.add(const Duration(minutes: 1)),
    );
    expect(breakDetail.session.status, StudySessionStatus.onBreak);
    expect(breakDetail.session.accumulatedFocusedSeconds, 60);
    final storedBreak = await database
        .select(database.localStudyBreaks)
        .getSingle();
    expect(storedBreak.notificationId, lessThan(0));

    final resumed = await repository.resumeSession(
      sessionId: 'session-1',
      profileId: profileId,
      nowUtc: start.add(const Duration(minutes: 6)),
    );
    expect(resumed.session.status, StudySessionStatus.running);
    expect(
      resumed.breaks.single.endedAtUtc,
      start.add(const Duration(minutes: 6)),
    );

    final stopped = await repository.stopSession(
      sessionId: 'session-1',
      profileId: profileId,
      nowUtc: start.add(const Duration(minutes: 9)),
    );
    expect(stopped.session.status, StudySessionStatus.stopped);
    expect(stopped.session.finalFocusedSeconds, 240);
    expect(stopped.session.focusedSecondsAt(start), 240);
    expect(await repository.getActiveSession(profileId), isNull);
  });

  test(
    'stopping during a break closes it without counting break minutes',
    () async {
      final start = DateTime.utc(2026, 10, 18, 3);
      await repository.startSession(
        id: 'session-break-stop',
        profileId: profileId,
        taskId: null,
        nowUtc: start,
      );
      await repository.takeBreak(
        sessionId: 'session-break-stop',
        profileId: profileId,
        breakId: 'break-stop',
        durationMinutes: 20,
        nowUtc: start.add(const Duration(minutes: 5)),
      );
      final stopped = await repository.stopSession(
        sessionId: 'session-break-stop',
        profileId: profileId,
        nowUtc: start.add(const Duration(minutes: 12)),
      );
      expect(stopped.session.finalFocusedSeconds, 300);
      expect(
        stopped.breaks.single.endedAtUtc,
        start.add(const Duration(minutes: 12)),
      );
    },
  );

  test('rejects access through a different profile', () async {
    await expectLater(
      repository.getActiveSession('someone-else'),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'links only an open task and preserves a session when task is deleted',
    () async {
      final now = DateTime.utc(2026, 10, 18, 3);
      final tasks = DriftTaskRepository(database, profileId);
      await tasks.createTask(
        Task(
          id: 'study-task',
          profileId: profileId,
          topic: 'Read chapter 4',
          startDate: TaskDate(2026, 10, 18),
          plannedEndDate: TaskDate(2026, 10, 19),
          effortHundredths: 100,
          status: TaskStatus.open,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final detail = await repository.startSession(
        id: 'linked-session',
        profileId: profileId,
        taskId: 'study-task',
        nowUtc: now,
      );
      expect(detail.session.taskId, 'study-task');

      expect(await tasks.deleteTask('study-task'), isTrue);
      final preservedSession = await repository.getActiveSessionDetail(
        profileId,
      );
      expect(preservedSession?.session.id, 'linked-session');
      expect(preservedSession?.session.taskId, isNull);
    },
  );

  test('schema v4 upgrade preserves the existing task data', () async {
    final directory = await Directory.systemTemp.createTemp(
      'mytasks-migration-',
    );
    final file = File(
      '${directory.path}${Platform.pathSeparator}upgrade.sqlite',
    );
    final beforeUpgrade = AppDatabase(NativeDatabase(file));
    final profile = await LocalProfileStore(beforeUpgrade)
        .getOrCreateGuestProfile();
    final now = DateTime.utc(2026, 10, 18, 3);
    await DriftTaskRepository(beforeUpgrade, profile.id).createTask(
      Task(
        id: 'kept-task',
        profileId: profile.id,
        topic: 'Migration check',
        startDate: TaskDate(2026, 10, 18),
        plannedEndDate: TaskDate(2026, 10, 19),
        effortHundredths: 150,
        status: TaskStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await beforeUpgrade.customStatement('DROP TABLE local_study_breaks');
    await beforeUpgrade.customStatement('DROP TABLE local_study_sessions');
    await beforeUpgrade.customStatement('PRAGMA user_version = 4');
    await beforeUpgrade.close();

    final afterUpgrade = AppDatabase(NativeDatabase(file));
    try {
      final task = await DriftTaskRepository(
        afterUpgrade,
        profile.id,
      ).getTask('kept-task');
      expect(task?.topic, 'Migration check');
      expect(afterUpgrade.schemaVersion, 5);
      expect(
        await afterUpgrade.select(afterUpgrade.localStudySessions).get(),
        isEmpty,
      );
      expect(
        await afterUpgrade.select(afterUpgrade.localStudyBreaks).get(),
        isEmpty,
      );
    } finally {
      await afterUpgrade.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'active focus and break recover after closing and reopening the database',
    () async {
      await database.close();
      database = AppDatabase(NativeDatabase.memory());
      final directory = await Directory.systemTemp.createTemp(
        'mytasks-recovery-',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}recovery.sqlite',
      );
      final original = AppDatabase(NativeDatabase(file));
      final profile = await LocalProfileStore(original)
          .getOrCreateGuestProfile();
      final originalRepository = DriftStudySessionRepository(
        original,
        profile.id,
      );
      final startedAt = DateTime.utc(2026, 10, 18, 9);
      await originalRepository.startSession(
        id: 'recovered-session',
        profileId: profile.id,
        taskId: null,
        nowUtc: startedAt,
      );
      await originalRepository.takeBreak(
        sessionId: 'recovered-session',
        profileId: profile.id,
        breakId: 'recovered-break',
        durationMinutes: 10,
        nowUtc: startedAt.add(const Duration(minutes: 25)),
      );
      await original.close();

      final reopened = AppDatabase(NativeDatabase(file));
      try {
        final recovered = await DriftStudySessionRepository(
          reopened,
          profile.id,
        ).getActiveSessionDetail(profile.id);
        expect(recovered?.session.status, StudySessionStatus.onBreak);
        expect(recovered?.session.accumulatedFocusedSeconds, 25 * 60);
        expect(
          recovered?.activeBreak?.plannedEndAtUtc,
          startedAt.add(const Duration(minutes: 35)),
        );
        expect(
          recovered?.session.focusedSecondsAt(
            startedAt.add(const Duration(hours: 1)),
          ),
          25 * 60,
        );
      } finally {
        await reopened.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
