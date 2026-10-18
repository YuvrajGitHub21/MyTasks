import '../entities/study_session.dart';
import '../entities/task.dart';

/// Computes focused study time by IST date from persisted focus/break bounds.
abstract final class StudyTimeCalculator {
  static const _istOffset = Duration(hours: 5, minutes: 30);

  static int focusedSecondsOnDate({
    required Iterable<StudySessionDetail> sessions,
    required TaskDate date,
    required DateTime nowUtc,
  }) {
    final startOfDayUtc = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).subtract(_istOffset);
    final endOfDayUtc = DateTime.utc(
      date.year,
      date.month,
      date.day + 1,
    ).subtract(_istOffset);

    var totalSeconds = 0;
    for (final detail in sessions) {
      for (final interval in _focusedIntervals(detail, nowUtc.toUtc())) {
        final start = interval.$1.isAfter(startOfDayUtc)
            ? interval.$1
            : startOfDayUtc;
        final end = interval.$2.isBefore(endOfDayUtc)
            ? interval.$2
            : endOfDayUtc;
        if (end.isAfter(start)) totalSeconds += end.difference(start).inSeconds;
      }
    }
    return totalSeconds;
  }

  static List<(DateTime, DateTime)> _focusedIntervals(
    StudySessionDetail detail,
    DateTime nowUtc,
  ) {
    final session = detail.session;
    final intervals = <(DateTime, DateTime)>[];
    var cursor = session.startedAtUtc.toUtc();
    final orderedBreaks = detail.breaks.toList()
      ..sort((a, b) => a.startedAtUtc.compareTo(b.startedAtUtc));

    for (final studyBreak in orderedBreaks) {
      final breakStart = studyBreak.startedAtUtc.toUtc();
      if (breakStart.isAfter(cursor)) intervals.add((cursor, breakStart));
      final breakEnd = studyBreak.endedAtUtc?.toUtc();
      if (breakEnd == null) return intervals;
      if (breakEnd.isAfter(cursor)) cursor = breakEnd;
    }

    final end = switch (session.status) {
      StudySessionStatus.running => nowUtc,
      StudySessionStatus.onBreak => null,
      StudySessionStatus.stopped => session.stoppedAtUtc?.toUtc(),
    };
    if (end != null && end.isAfter(cursor)) intervals.add((cursor, end));
    return intervals;
  }
}
