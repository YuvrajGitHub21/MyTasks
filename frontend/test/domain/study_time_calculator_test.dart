import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/domain/entities/study_session.dart';
import 'package:mytasks/domain/entities/task.dart';
import 'package:mytasks/domain/rules/study_time_calculator.dart';

void main() {
  group('StudyTimeCalculator', () {
    test('splits elapsed focus at the IST calendar boundary', () {
      final session = _detail(
        started: DateTime.utc(2026, 10, 17, 18, 20),
        status: StudySessionStatus.stopped,
        stopped: DateTime.utc(2026, 10, 17, 18, 40),
        finalSeconds: 1200,
      );
      final seconds = StudyTimeCalculator.focusedSecondsOnDate(
        sessions: [session],
        date: TaskDate(2026, 10, 18),
        nowUtc: DateTime.utc(2026, 10, 18),
      );
      expect(seconds, 600);
    });

    test('excludes break time from completed focus total', () {
      final start = DateTime.utc(2026, 10, 18, 3);
      final detail = _detail(
        started: start,
        status: StudySessionStatus.stopped,
        stopped: start.add(const Duration(minutes: 30)),
        finalSeconds: 1200,
        breaks: [
          StudyBreak(
            id: 'break',
            profileId: 'profile',
            sessionId: 'session',
            startedAtUtc: start.add(const Duration(minutes: 10)),
            plannedEndAtUtc: start.add(const Duration(minutes: 20)),
            endedAtUtc: start.add(const Duration(minutes: 20)),
          ),
        ],
      );
      expect(
        StudyTimeCalculator.focusedSecondsOnDate(
          sessions: [detail],
          date: TaskDate(2026, 10, 18),
          nowUtc: start.add(const Duration(minutes: 30)),
        ),
        1200,
      );
    });

    test('does not count the rest of a session while it is on break', () {
      final start = DateTime.utc(2026, 10, 18, 3);
      final detail = _detail(
        started: start,
        status: StudySessionStatus.onBreak,
        accumulated: 600,
        breaks: [
          StudyBreak(
            id: 'break',
            profileId: 'profile',
            sessionId: 'session',
            startedAtUtc: start.add(const Duration(minutes: 10)),
            plannedEndAtUtc: start.add(const Duration(minutes: 20)),
          ),
        ],
      );
      expect(
        StudyTimeCalculator.focusedSecondsOnDate(
          sessions: [detail],
          date: TaskDate(2026, 10, 18),
          nowUtc: start.add(const Duration(minutes: 25)),
        ),
        600,
      );
    });
  });
}

StudySessionDetail _detail({
  required DateTime started,
  required StudySessionStatus status,
  DateTime? stopped,
  int accumulated = 0,
  int? finalSeconds,
  List<StudyBreak> breaks = const [],
}) => StudySessionDetail(
  session: StudySession(
    id: 'session',
    profileId: 'profile',
    status: status,
    startedAtUtc: started,
    activeFocusStartedAtUtc: status == StudySessionStatus.running
        ? started
        : null,
    accumulatedFocusedSeconds: accumulated,
    stoppedAtUtc: stopped,
    finalFocusedSeconds: finalSeconds,
    createdAtUtc: started,
    updatedAtUtc: stopped ?? started,
  ),
  breaks: breaks,
);
