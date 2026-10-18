import 'package:uuid/uuid.dart';

import '../../domain/entities/study_session.dart';
import '../../domain/repositories/study_session_repository.dart';
import '../../domain/rules/study_session_rules.dart';
import '../../domain/services/study_break_alert_scheduler.dart';
import '../../domain/services/diagnostic_logger.dart';

abstract interface class StudyClock {
  DateTime nowUtc();
}

final class SystemStudyClock implements StudyClock {
  const SystemStudyClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

final class StudySessionActionResult {
  const StudySessionActionResult({
    required this.detail,
    required this.platformAlertHandled,
  });

  final StudySessionDetail detail;

  /// False means the persisted study transition succeeded but OS alert work
  /// failed. The UI can explain that the timer itself remains active.
  final bool platformAlertHandled;
}

final class StartStudySession {
  StartStudySession({
    required StudySessionRepository repository,
    required StudyClock clock,
    Uuid? uuid,
    this._logger = const NoopDiagnosticLogger(),
  }) : _repository = repository,
       _clock = clock,
       _uuid = uuid ?? const Uuid();

  final StudySessionRepository _repository;
  final StudyClock _clock;
  final Uuid _uuid;
  final DiagnosticLogger _logger;

  Future<StudySessionDetail> call({
    required String profileId,
    String? taskId,
  }) => runDiagnosticOperation(
    logger: _logger,
    feature: 'study',
    eventName: 'study.session.start',
    action: () async {
      final active = await _repository.getActiveSession(profileId);
      StudySessionRules.ensureCanStart(active);
      return _repository.startSession(
        id: _uuid.v4(),
        profileId: profileId,
        taskId: taskId,
        nowUtc: _clock.nowUtc(),
      );
    },
  );
}

final class TakeStudyBreak {
  TakeStudyBreak({
    required StudySessionRepository repository,
    required StudyBreakAlertScheduler alertScheduler,
    required StudyClock clock,
    Uuid? uuid,
    this._logger = const NoopDiagnosticLogger(),
  }) : _repository = repository,
       _alertScheduler = alertScheduler,
       _clock = clock,
       _uuid = uuid ?? const Uuid();

  final StudySessionRepository _repository;
  final StudyBreakAlertScheduler _alertScheduler;
  final StudyClock _clock;
  final Uuid _uuid;
  final DiagnosticLogger _logger;

  Future<StudySessionActionResult> call({
    required String profileId,
    required String sessionId,
    required int durationMinutes,
  }) => runDiagnosticOperation(
    logger: _logger,
    feature: 'study',
    eventName: 'study.break.start',
    action: () async {
      StudySessionRules.validateBreakMinutes(durationMinutes);
      final active = await _repository.getActiveSession(profileId);
      if (active == null || active.id != sessionId) {
        throw const StudySessionRuleException(
          'The active study session could not be found.',
        );
      }
      StudySessionRules.ensureCanTakeBreak(active);
      final detail = await _repository.takeBreak(
        sessionId: sessionId,
        profileId: profileId,
        breakId: _uuid.v4(),
        durationMinutes: durationMinutes,
        nowUtc: _clock.nowUtc(),
      );
      final activeBreak = detail.activeBreak;
      if (activeBreak == null) {
        throw StateError('The break was saved without an active break record.');
      }
      var alertHandled = true;
      try {
        await _alertScheduler.schedule(
          breakId: activeBreak.id,
          plannedEndAtUtc: activeBreak.plannedEndAtUtc,
        );
      } catch (_) {
        alertHandled = false;
        try {
          _logger.failure(
            'study.break_alert.schedule.failed',
            feature: 'study',
            error: StateError('Platform alert scheduling failed.'),
            stackTrace: StackTrace.current,
          );
        } catch (_) {}
      }
      return StudySessionActionResult(
        detail: detail,
        platformAlertHandled: alertHandled,
      );
    },
    attributes: {'breakMinutes': durationMinutes},
  );
}

final class ResumeStudySession {
  ResumeStudySession({
    required StudySessionRepository repository,
    required StudyBreakAlertScheduler alertScheduler,
    required StudyClock clock,
    this._logger = const NoopDiagnosticLogger(),
  }) : _repository = repository,
       _alertScheduler = alertScheduler,
       _clock = clock;

  final StudySessionRepository _repository;
  final StudyBreakAlertScheduler _alertScheduler;
  final StudyClock _clock;
  final DiagnosticLogger _logger;

  Future<StudySessionActionResult> call({
    required String profileId,
    required String sessionId,
  }) => runDiagnosticOperation(
    logger: _logger,
    feature: 'study',
    eventName: 'study.break.end',
    action: () async {
      final active = await _repository.getActiveSessionDetail(profileId);
      if (active == null || active.session.id != sessionId) {
        throw const StudySessionRuleException(
          'The active study session could not be found.',
        );
      }
      StudySessionRules.ensureCanResume(active.session);
      final breakId = active.activeBreak?.id;
      final detail = await _repository.resumeSession(
        sessionId: sessionId,
        profileId: profileId,
        nowUtc: _clock.nowUtc(),
      );
      var alertHandled = true;
      if (breakId != null) {
        try {
          await _alertScheduler.cancel(breakId);
        } catch (_) {
          alertHandled = false;
          try {
            _logger.failure(
              'study.break_alert.cancel.failed',
              feature: 'study',
              error: StateError('Platform alert cancellation failed.'),
              stackTrace: StackTrace.current,
            );
          } catch (_) {}
        }
      }
      return StudySessionActionResult(
        detail: detail,
        platformAlertHandled: alertHandled,
      );
    },
  );
}

final class StopStudySession {
  StopStudySession({
    required StudySessionRepository repository,
    required StudyBreakAlertScheduler alertScheduler,
    required StudyClock clock,
    this._logger = const NoopDiagnosticLogger(),
  }) : _repository = repository,
       _alertScheduler = alertScheduler,
       _clock = clock;

  final StudySessionRepository _repository;
  final StudyBreakAlertScheduler _alertScheduler;
  final StudyClock _clock;
  final DiagnosticLogger _logger;

  Future<StudySessionActionResult> call({
    required String profileId,
    required String sessionId,
  }) => runDiagnosticOperation(
    logger: _logger,
    feature: 'study',
    eventName: 'study.session.stop',
    action: () async {
      final active = await _repository.getActiveSessionDetail(profileId);
      if (active == null || active.session.id != sessionId) {
        throw const StudySessionRuleException(
          'The active study session could not be found.',
        );
      }
      StudySessionRules.ensureCanStop(active.session);
      final breakId = active.activeBreak?.id;
      final detail = await _repository.stopSession(
        sessionId: sessionId,
        profileId: profileId,
        nowUtc: _clock.nowUtc(),
      );
      var alertHandled = true;
      if (breakId != null) {
        try {
          await _alertScheduler.cancel(breakId);
        } catch (_) {
          alertHandled = false;
          try {
            _logger.failure(
              'study.break_alert.cancel.failed',
              feature: 'study',
              error: StateError('Platform alert cancellation failed.'),
              stackTrace: StackTrace.current,
            );
          } catch (_) {}
        }
      }
      return StudySessionActionResult(
        detail: detail,
        platformAlertHandled: alertHandled,
      );
    },
  );
}
