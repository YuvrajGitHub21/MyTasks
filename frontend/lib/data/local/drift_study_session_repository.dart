import 'package:drift/drift.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/repositories/study_session_repository.dart';
import 'app_database.dart';

/// Profile-scoped Drift adapter for study sessions and their break intervals.
/// Every state transition and its timestamps are saved in one SQLite transaction.
final class DriftStudySessionRepository implements StudySessionRepository {
  DriftStudySessionRepository(this._database, this._profileId);

  final AppDatabase _database;
  final String _profileId;

  @override
  Stream<StudySessionDetail?> watchActiveSession(String profileId) =>
      _watchSessionIds(
        profileId,
        where: "status IN ('RUNNING', 'ON_BREAK')",
        limit: 1,
      ).asyncMap((ids) async => ids.isEmpty ? null : _getDetail(ids.single));

  @override
  Stream<List<StudySessionDetail>> watchRecentSessions(
    String profileId, {
    int limit = 50,
  }) => _watchSessionIds(profileId, where: '1 = 1', limit: limit.clamp(1, 500))
      .asyncMap((ids) async {
        final details = <StudySessionDetail>[];
        for (final id in ids) {
          final detail = await _getDetail(id);
          if (detail != null) details.add(detail);
        }
        return details;
      });

  @override
  Future<List<StudySessionDetail>> getSessionsForDateRange({
    required String profileId,
    required DateTime fromUtc,
    required DateTime toUtc,
  }) async {
    _ensureProfile(profileId);
    if (!fromUtc.isBefore(toUtc)) {
      throw ArgumentError(
        'The study date range must have a positive duration.',
      );
    }
    final rows =
        await (_database.select(_database.localStudySessions)
              ..where(
                (row) =>
                    row.profileId.equals(_profileId) &
                    row.startedAtUtc.isSmallerThanValue(toUtc.toUtc()) &
                    (row.stoppedAtUtc.isNull() |
                        row.stoppedAtUtc.isBiggerOrEqualValue(fromUtc.toUtc())),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.startedAtUtc)]))
            .get();
    final details = <StudySessionDetail>[];
    for (final row in rows) {
      final detail = await _getDetail(row.id);
      if (detail != null) details.add(detail);
    }
    return details;
  }

  @override
  Future<StudySession?> getActiveSession(String profileId) async {
    _ensureProfile(profileId);
    final row =
        await (_database.select(_database.localStudySessions)
              ..where(
                (session) =>
                    session.profileId.equals(_profileId) &
                    session.status.isNotValue('STOPPED'),
              )
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toSession(row);
  }

  @override
  Future<StudySessionDetail?> getActiveSessionDetail(String profileId) async {
    final session = await getActiveSession(profileId);
    return session == null ? null : _getDetail(session.id);
  }

  @override
  Future<StudySessionDetail> startSession({
    required String id,
    required String profileId,
    required String? taskId,
    required DateTime nowUtc,
  }) async {
    _ensureProfile(profileId);
    _validateId(id, 'session');
    final now = nowUtc.toUtc();
    return _database.transaction(() async {
      if (taskId != null) {
        final task =
            await (_database.select(_database.localTasks)..where(
                  (row) =>
                      row.id.equals(taskId) & row.profileId.equals(_profileId),
                ))
                .getSingleOrNull();
        if (task == null || task.status != 'OPEN') {
          throw StateError('Choose an open task belonging to this profile.');
        }
      }
      final existing =
          await (_database.select(_database.localStudySessions)
                ..where(
                  (row) =>
                      row.profileId.equals(_profileId) &
                      row.status.isNotValue('STOPPED'),
                )
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) {
        throw StateError('Stop or resume the active study session first.');
      }
      await _database
          .into(_database.localStudySessions)
          .insert(
            LocalStudySessionsCompanion.insert(
              id: id,
              profileId: _profileId,
              taskId: Value(taskId),
              status: 'RUNNING',
              startedAtUtc: now,
              activeFocusStartedAtUtc: Value(now),
              createdAtUtc: now,
              updatedAtUtc: now,
            ),
          );
      return _getRequiredDetail(id);
    });
  }

  @override
  Future<StudySessionDetail> takeBreak({
    required String sessionId,
    required String profileId,
    required String breakId,
    required int durationMinutes,
    required DateTime nowUtc,
  }) async {
    _ensureProfile(profileId);
    _validateId(breakId, 'break');
    if (durationMinutes < 1 || durationMinutes > 240) {
      throw ArgumentError.value(durationMinutes, 'durationMinutes');
    }
    final now = nowUtc.toUtc();
    return _database.transaction(() async {
      final session = await _activeSessionRow(sessionId);
      if (session.status != 'RUNNING' ||
          session.activeFocusStartedAtUtc == null) {
        throw StateError('A break can only start while the timer is running.');
      }
      final focused = now
          .difference(session.activeFocusStartedAtUtc!.toUtc())
          .inSeconds;
      final nextNotificationId = await _allocateNotificationId();
      await (_database.update(_database.localStudySessions)..where(
            (row) =>
                row.id.equals(sessionId) & row.profileId.equals(_profileId),
          ))
          .write(
            LocalStudySessionsCompanion(
              status: const Value('ON_BREAK'),
              activeFocusStartedAtUtc: const Value(null),
              accumulatedFocusedSeconds: Value(
                session.accumulatedFocusedSeconds + (focused > 0 ? focused : 0),
              ),
              updatedAtUtc: Value(now),
            ),
          );
      await _database
          .into(_database.localStudyBreaks)
          .insert(
            LocalStudyBreaksCompanion.insert(
              id: breakId,
              profileId: _profileId,
              sessionId: sessionId,
              startedAtUtc: now,
              plannedEndAtUtc: now.add(Duration(minutes: durationMinutes)),
              notificationId: nextNotificationId,
            ),
          );
      return _getRequiredDetail(sessionId);
    });
  }

  @override
  Future<StudySessionDetail> resumeSession({
    required String sessionId,
    required String profileId,
    required DateTime nowUtc,
  }) async {
    _ensureProfile(profileId);
    final now = nowUtc.toUtc();
    return _database.transaction(() async {
      final session = await _activeSessionRow(sessionId);
      if (session.status != 'ON_BREAK') {
        throw StateError('There is no break to resume from.');
      }
      final openBreak =
          await (_database.select(_database.localStudyBreaks)
                ..where(
                  (row) =>
                      row.sessionId.equals(sessionId) &
                      row.profileId.equals(_profileId) &
                      row.endedAtUtc.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      if (openBreak == null) {
        throw StateError('The active break record is missing.');
      }
      await (_database.update(_database.localStudyBreaks)..where(
            (row) =>
                row.id.equals(openBreak.id) & row.profileId.equals(_profileId),
          ))
          .write(LocalStudyBreaksCompanion(endedAtUtc: Value(now)));
      await (_database.update(_database.localStudySessions)..where(
            (row) =>
                row.id.equals(sessionId) & row.profileId.equals(_profileId),
          ))
          .write(
            LocalStudySessionsCompanion(
              status: const Value('RUNNING'),
              activeFocusStartedAtUtc: Value(now),
              updatedAtUtc: Value(now),
            ),
          );
      return _getRequiredDetail(sessionId);
    });
  }

  @override
  Future<StudySessionDetail> stopSession({
    required String sessionId,
    required String profileId,
    required DateTime nowUtc,
  }) async {
    _ensureProfile(profileId);
    final now = nowUtc.toUtc();
    return _database.transaction(() async {
      final session = await _activeSessionRow(sessionId);
      var focusedSeconds = session.accumulatedFocusedSeconds;
      if (session.status == 'RUNNING' &&
          session.activeFocusStartedAtUtc != null) {
        final additional = now
            .difference(session.activeFocusStartedAtUtc!.toUtc())
            .inSeconds;
        if (additional > 0) focusedSeconds += additional;
      }
      final openBreak =
          await (_database.select(_database.localStudyBreaks)
                ..where(
                  (row) =>
                      row.sessionId.equals(sessionId) &
                      row.profileId.equals(_profileId) &
                      row.endedAtUtc.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      if (openBreak != null) {
        await (_database.update(_database.localStudyBreaks)..where(
              (row) =>
                  row.id.equals(openBreak.id) &
                  row.profileId.equals(_profileId),
            ))
            .write(LocalStudyBreaksCompanion(endedAtUtc: Value(now)));
      }
      await (_database.update(_database.localStudySessions)..where(
            (row) =>
                row.id.equals(sessionId) & row.profileId.equals(_profileId),
          ))
          .write(
            LocalStudySessionsCompanion(
              status: const Value('STOPPED'),
              activeFocusStartedAtUtc: const Value(null),
              stoppedAtUtc: Value(now),
              finalFocusedSeconds: Value(focusedSeconds),
              updatedAtUtc: Value(now),
            ),
          );
      return _getRequiredDetail(sessionId);
    });
  }

  Stream<List<String>> _watchSessionIds(
    String profileId, {
    required String where,
    required int limit,
  }) {
    _ensureProfile(profileId);
    return _database
        .customSelect(
          'SELECT id FROM local_study_sessions WHERE profile_id = ? AND $where '
          'ORDER BY started_at_utc DESC LIMIT ?',
          variables: [Variable.withString(_profileId), Variable.withInt(limit)],
          readsFrom: {_database.localStudySessions, _database.localStudyBreaks},
        )
        .watch()
        .map((rows) => rows.map((row) => row.read<String>('id')).toList());
  }

  Future<StudySessionDetail?> _getDetail(String id) async {
    final session =
        await (_database.select(_database.localStudySessions)..where(
              (row) => row.id.equals(id) & row.profileId.equals(_profileId),
            ))
            .getSingleOrNull();
    if (session == null) return null;
    final breaks =
        await (_database.select(_database.localStudyBreaks)
              ..where(
                (row) =>
                    row.sessionId.equals(id) & row.profileId.equals(_profileId),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.startedAtUtc)]))
            .get();
    return StudySessionDetail(
      session: _toSession(session),
      breaks: [for (final row in breaks) _toBreak(row)],
    );
  }

  Future<StudySessionRecord> _activeSessionRow(String id) async {
    final row =
        await (_database.select(_database.localStudySessions)..where(
              (session) =>
                  session.id.equals(id) &
                  session.profileId.equals(_profileId) &
                  session.status.isNotValue('STOPPED'),
            ))
            .getSingleOrNull();
    if (row == null) {
      throw StateError('The active study session was not found.');
    }
    return row;
  }

  Future<int> _allocateNotificationId() async {
    final ids = await _database.select(_database.localStudyBreaks).get();
    final mostNegative = ids.fold<int>(
      0,
      (value, row) => row.notificationId < value ? row.notificationId : value,
    );
    if (mostNegative <= -2147483647) {
      throw StateError('No study break notification IDs are available.');
    }
    return mostNegative - 1;
  }

  Future<StudySessionDetail> _getRequiredDetail(String id) async {
    final detail = await _getDetail(id);
    if (detail == null) {
      throw StateError('The study session could not be read.');
    }
    return detail;
  }

  void _ensureProfile(String profileId) {
    if (profileId != _profileId) {
      throw StateError(
        'Study data cannot be accessed from a different profile.',
      );
    }
  }

  void _validateId(String id, String kind) {
    if (id.trim().isEmpty || id.length > 100) {
      throw ArgumentError(
        '$kind ID must contain between 1 and 100 characters.',
      );
    }
  }

  StudySession _toSession(StudySessionRecord row) => StudySession(
    id: row.id,
    profileId: row.profileId,
    taskId: row.taskId,
    status: switch (row.status) {
      'RUNNING' => StudySessionStatus.running,
      'ON_BREAK' => StudySessionStatus.onBreak,
      'STOPPED' => StudySessionStatus.stopped,
      _ => throw StateError('Unknown study session state.'),
    },
    startedAtUtc: row.startedAtUtc.toUtc(),
    activeFocusStartedAtUtc: row.activeFocusStartedAtUtc?.toUtc(),
    accumulatedFocusedSeconds: row.accumulatedFocusedSeconds,
    stoppedAtUtc: row.stoppedAtUtc?.toUtc(),
    finalFocusedSeconds: row.finalFocusedSeconds,
    createdAtUtc: row.createdAtUtc.toUtc(),
    updatedAtUtc: row.updatedAtUtc.toUtc(),
  );

  StudyBreak _toBreak(StudyBreakRecord row) => StudyBreak(
    id: row.id,
    profileId: row.profileId,
    sessionId: row.sessionId,
    startedAtUtc: row.startedAtUtc.toUtc(),
    plannedEndAtUtc: row.plannedEndAtUtc.toUtc(),
    endedAtUtc: row.endedAtUtc?.toUtc(),
  );
}
