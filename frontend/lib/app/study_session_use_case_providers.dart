import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/study/study_session_use_cases.dart';
import '../domain/entities/study_session.dart';
import '../data/local/database_providers.dart';
import '../data/local/study_session_repository_provider.dart';
import '../data/notifications/flutter_study_break_alert_scheduler.dart';
import '../domain/repositories/study_session_repository.dart';
import '../domain/entities/task.dart';
import '../data/local/task_repository_provider.dart';

final studySessionUseCasesProvider = FutureProvider<StudySessionUseCases>((
  ref,
) async {
  final repository = await ref.watch(studySessionRepositoryProvider.future);
  final profile = await ref.watch(activeProfileProvider.future);
  final database = await ref.watch(appDatabaseProvider.future);
  final scheduler = FlutterStudyBreakAlertScheduler(
    database: database,
    profileId: profile.id,
  );
  return StudySessionUseCases(
    profileId: profile.id,
    repository: repository,
    alertScheduler: scheduler,
    start: StartStudySession(
      repository: repository,
      clock: const SystemStudyClock(),
    ),
    takeBreak: TakeStudyBreak(
      repository: repository,
      alertScheduler: scheduler,
      clock: const SystemStudyClock(),
    ),
    resume: ResumeStudySession(
      repository: repository,
      alertScheduler: scheduler,
      clock: const SystemStudyClock(),
    ),
    stop: StopStudySession(
      repository: repository,
      alertScheduler: scheduler,
      clock: const SystemStudyClock(),
    ),
  );
});

final activeStudySessionProvider = StreamProvider<StudySessionDetail?>((
  ref,
) async* {
  final useCases = await ref.watch(studySessionUseCasesProvider.future);
  yield* useCases.repository.watchActiveSession(useCases.profileId);
});

final recentStudySessionsProvider = StreamProvider<List<StudySessionDetail>>((
  ref,
) async* {
  final useCases = await ref.watch(studySessionUseCasesProvider.future);
  yield* useCases.repository.watchRecentSessions(useCases.profileId);
});

final studyAvailableTasksProvider = StreamProvider<List<Task>>((ref) async* {
  final repository = await ref.watch(taskRepositoryProvider.future);
  yield* repository.watchTasks().map(
    (tasks) =>
        tasks.where((task) => task.status == TaskStatus.open).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate)),
  );
});

final class StudySessionUseCases {
  const StudySessionUseCases({
    required this.profileId,
    required this.repository,
    required this.alertScheduler,
    required this.start,
    required this.takeBreak,
    required this.resume,
    required this.stop,
  });

  final String profileId;
  final StudySessionRepository repository;
  final FlutterStudyBreakAlertScheduler alertScheduler;
  final StartStudySession start;
  final TakeStudyBreak takeBreak;
  final ResumeStudySession resume;
  final StopStudySession stop;
}
