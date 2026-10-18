import '../entities/study_session.dart';

abstract final class StudySessionRules {
  static const minimumBreakMinutes = 1;
  static const maximumBreakMinutes = 240;

  static void ensureCanStart(StudySession? activeSession) {
    if (activeSession != null && activeSession.isActive) {
      throw const StudySessionRuleException(
        'Finish or stop the active study session before starting another.',
      );
    }
  }

  static void ensureCanTakeBreak(StudySession session) {
    if (session.status != StudySessionStatus.running) {
      throw const StudySessionRuleException(
        'A break can only start while a study session is running.',
      );
    }
  }

  static void ensureCanResume(StudySession session) {
    if (session.status != StudySessionStatus.onBreak) {
      throw const StudySessionRuleException(
        'There is no active break to resume from.',
      );
    }
  }

  static void ensureCanStop(StudySession session) {
    if (session.status == StudySessionStatus.stopped) {
      throw const StudySessionRuleException(
        'This study session is already stopped.',
      );
    }
  }

  static void validateBreakMinutes(int minutes) {
    if (minutes < minimumBreakMinutes || minutes > maximumBreakMinutes) {
      throw StudySessionRuleException(
        'Choose a break from $minimumBreakMinutes to $maximumBreakMinutes minutes.',
      );
    }
  }
}

final class StudySessionRuleException implements Exception {
  const StudySessionRuleException(this.message);

  final String message;

  @override
  String toString() => message;
}
