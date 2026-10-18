import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/domain/entities/study_session.dart';
import 'package:mytasks/domain/rules/study_session_rules.dart';

void main() {
  group('StudySessionRules', () {
    test('accepts only a single active session', () {
      expect(() => StudySessionRules.ensureCanStart(null), returnsNormally);
      expect(
        () => StudySessionRules.ensureCanStart(
          _session(StudySessionStatus.running),
        ),
        throwsA(isA<StudySessionRuleException>()),
      );
      expect(
        () => StudySessionRules.ensureCanStart(
          _session(StudySessionStatus.onBreak),
        ),
        throwsA(isA<StudySessionRuleException>()),
      );
    });

    test('allows custom breaks from 1 through 240 minutes', () {
      for (final minutes in [1, 10, 20, 240]) {
        expect(
          () => StudySessionRules.validateBreakMinutes(minutes),
          returnsNormally,
        );
      }
      for (final minutes in [0, 241, -1]) {
        expect(
          () => StudySessionRules.validateBreakMinutes(minutes),
          throwsA(isA<StudySessionRuleException>()),
        );
      }
    });

    test('break, resume, and stop enforce valid states', () {
      expect(
        () => StudySessionRules.ensureCanTakeBreak(
          _session(StudySessionStatus.onBreak),
        ),
        throwsA(isA<StudySessionRuleException>()),
      );
      expect(
        () => StudySessionRules.ensureCanResume(
          _session(StudySessionStatus.running),
        ),
        throwsA(isA<StudySessionRuleException>()),
      );
      expect(
        () => StudySessionRules.ensureCanStop(
          _session(StudySessionStatus.stopped),
        ),
        throwsA(isA<StudySessionRuleException>()),
      );
    });
  });
}

StudySession _session(StudySessionStatus status) {
  final now = DateTime.utc(2026, 10, 18, 8);
  return StudySession(
    id: 'session',
    profileId: 'profile',
    status: status,
    startedAtUtc: now,
    activeFocusStartedAtUtc: status == StudySessionStatus.running ? now : null,
    accumulatedFocusedSeconds: 0,
    stoppedAtUtc: status == StudySessionStatus.stopped ? now : null,
    finalFocusedSeconds: status == StudySessionStatus.stopped ? 0 : null,
    createdAtUtc: now,
    updatedAtUtc: now,
  );
}
