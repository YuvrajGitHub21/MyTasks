import 'task.dart';

enum StudySessionStatus { running, onBreak, stopped }

/// One deliberately started period of focused study.
///
/// Timestamps are UTC instants. The active focus segment and accumulated
/// seconds let the app recover an accurate display after process recreation.
final class StudySession {
  const StudySession({
    required this.id,
    required this.profileId,
    required this.status,
    required this.startedAtUtc,
    required this.accumulatedFocusedSeconds,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.taskId,
    this.activeFocusStartedAtUtc,
    this.stoppedAtUtc,
    this.finalFocusedSeconds,
  });

  final String id;
  final String profileId;
  final String? taskId;
  final StudySessionStatus status;
  final DateTime startedAtUtc;
  final DateTime? activeFocusStartedAtUtc;
  final int accumulatedFocusedSeconds;
  final DateTime? stoppedAtUtc;
  final int? finalFocusedSeconds;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  int focusedSecondsAt(DateTime instant) {
    if (status == StudySessionStatus.stopped) {
      return finalFocusedSeconds ?? accumulatedFocusedSeconds;
    }
    if (status != StudySessionStatus.running ||
        activeFocusStartedAtUtc == null) {
      return accumulatedFocusedSeconds;
    }
    final extra = instant
        .toUtc()
        .difference(activeFocusStartedAtUtc!)
        .inSeconds;
    return accumulatedFocusedSeconds + (extra > 0 ? extra : 0);
  }

  bool get isActive => status != StudySessionStatus.stopped;
}

/// One pause in focused time. A null [endedAtUtc] means the break is active.
final class StudyBreak {
  const StudyBreak({
    required this.id,
    required this.profileId,
    required this.sessionId,
    required this.startedAtUtc,
    required this.plannedEndAtUtc,
    this.endedAtUtc,
  });

  final String id;
  final String profileId;
  final String sessionId;
  final DateTime startedAtUtc;
  final DateTime plannedEndAtUtc;
  final DateTime? endedAtUtc;

  DateTime endForAccounting(DateTime nowUtc) => endedAtUtc ?? nowUtc.toUtc();

  int durationSecondsAt(DateTime nowUtc) {
    final seconds = endForAccounting(nowUtc).difference(startedAtUtc).inSeconds;
    return seconds > 0 ? seconds : 0;
  }
}

final class StudySessionDetail {
  const StudySessionDetail({required this.session, required this.breaks});

  final StudySession session;
  final List<StudyBreak> breaks;

  StudyBreak? get activeBreak {
    for (final studyBreak in breaks.reversed) {
      if (studyBreak.endedAtUtc == null) return studyBreak;
    }
    return null;
  }

  int breakSecondsAt(DateTime nowUtc) => breaks.fold<int>(
    0,
    (total, studyBreak) => total + studyBreak.durationSecondsAt(nowUtc),
  );
}

final class StudyDayTotal {
  const StudyDayTotal({required this.date, required this.focusedSeconds});

  final TaskDate date;
  final int focusedSeconds;
}
