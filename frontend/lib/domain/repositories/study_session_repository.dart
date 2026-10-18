import '../entities/study_session.dart';

abstract interface class StudySessionRepository {
  Stream<StudySessionDetail?> watchActiveSession(String profileId);

  Stream<List<StudySessionDetail>> watchRecentSessions(
    String profileId, {
    int limit = 50,
  });

  Future<List<StudySessionDetail>> getSessionsForDateRange({
    required String profileId,
    required DateTime fromUtc,
    required DateTime toUtc,
  });

  Future<StudySession?> getActiveSession(String profileId);

  Future<StudySessionDetail?> getActiveSessionDetail(String profileId);

  Future<StudySessionDetail> startSession({
    required String id,
    required String profileId,
    required String? taskId,
    required DateTime nowUtc,
  });

  Future<StudySessionDetail> takeBreak({
    required String sessionId,
    required String profileId,
    required String breakId,
    required int durationMinutes,
    required DateTime nowUtc,
  });

  Future<StudySessionDetail> resumeSession({
    required String sessionId,
    required String profileId,
    required DateTime nowUtc,
  });

  Future<StudySessionDetail> stopSession({
    required String sessionId,
    required String profileId,
    required DateTime nowUtc,
  });
}
