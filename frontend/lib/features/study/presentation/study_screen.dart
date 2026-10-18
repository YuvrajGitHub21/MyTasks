import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/study_session_use_case_providers.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/rules/study_time_calculator.dart';
import '../../tasks/presentation/task_form_screen.dart';
import 'study_focus_screen.dart';
import 'study_history_widgets.dart';
import 'study_session_widgets.dart';

/// A local-first study stopwatch. Persisted UTC timestamps, not the UI ticker,
/// are the source of truth for elapsed time across app restarts.
class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({super.key});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
    with WidgetsBindingObserver {
  Timer? _displayTicker;
  DateTime _nowUtc = DateTime.now().toUtc();
  bool _busy = false;
  bool _choosingTask = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _displayTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _nowUtc = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _displayTicker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _nowUtc = DateTime.now().toUtc());
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeStudySessionProvider);
    final history = ref.watch(recentStudySessionsProvider);
    final total = history.when(
      data: (sessions) => StudyTimeCalculator.focusedSecondsOnDate(
        sessions: sessions,
        date: TaskDate.todayInIst(_nowUtc),
        nowUtc: _nowUtc,
      ),
      loading: () => null,
      error: (_, _) => null,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        TodayFocusSummary(seconds: total),
        const SizedBox(height: 20),
        active.when(
          data: (detail) => detail == null
              ? StartStudyCard(
                  onStart: _chooseAndStart,
                  busy: _busy || _choosingTask,
                  loading: _choosingTask,
                )
              : ActiveStudyCard(
                  detail: detail,
                  nowUtc: _nowUtc,
                  busy: _busy,
                  onFocus: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          StudyFocusScreen(sessionId: detail.session.id),
                    ),
                  ),
                  onBreak: _chooseBreak,
                  onResume: () => _resume(detail.session.id),
                  onStop: () => _stop(detail.session.id),
                ),
          loading: () => const StudyLoadingCard(),
          error: (_, _) => const StudyErrorCard(),
        ),
        const SizedBox(height: 28),
        Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        history.when(
          data: (sessions) => sessions.isEmpty
              ? const HistoryEmptyCard()
              : Column(
                  children: [
                    for (final detail in sessions.take(12))
                      StudyHistoryCard(detail: detail, nowUtc: _nowUtc),
                  ],
                ),
          loading: () => const StudyLoadingCard(),
          error: (_, _) => const StudyErrorCard(),
        ),
      ],
    );
  }

  Future<void> _chooseAndStart() async {
    if (_busy || _choosingTask) return;
    setState(() => _choosingTask = true);
    try {
      final choice = await showModalBottomSheet<StartChoice>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => const TaskChoiceSheet(),
      );
      if (!mounted || choice == null) return;

      String? taskId;
      if (choice.createNewTask) {
        taskId = await Navigator.of(context).push<String>(
          MaterialPageRoute<String>(
            builder: (_) => const TaskFormScreen(returnCreatedTaskId: true),
          ),
        );
        if (!mounted || taskId == null) return;
      } else {
        taskId = choice.taskId;
      }

      await _perform(() async {
        final useCases = await ref.read(studySessionUseCasesProvider.future);
        await useCases.start(profileId: useCases.profileId, taskId: taskId);
      });
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _choosingTask = false);
    }
  }

  Future<void> _chooseBreak(String sessionId) async {
    final minutes = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const BreakChoiceSheet(),
    );
    if (!mounted || minutes == null) return;
    await _perform(() async {
      final useCases = await ref.read(studySessionUseCasesProvider.future);
      final result = await useCases.takeBreak(
        profileId: useCases.profileId,
        sessionId: sessionId,
        durationMinutes: minutes,
      );
      if (!result.platformAlertHandled && mounted) {
        _showMessage(
          'Break started. The device could not schedule its end alert.',
        );
      }
    });
  }

  Future<void> _resume(String sessionId) => _perform(() async {
    final useCases = await ref.read(studySessionUseCasesProvider.future);
    final result = await useCases.resume(
      profileId: useCases.profileId,
      sessionId: sessionId,
    );
    if (!result.platformAlertHandled && mounted) {
      _showMessage(
        'Study resumed, but the old break alert could not be cleared.',
      );
    }
  });

  Future<void> _stop(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish this study session?'),
        content: const Text(
          'Focused time will be saved. Break time is excluded from your total.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep studying'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop session'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _perform(() async {
      final useCases = await ref.read(studySessionUseCasesProvider.future);
      final result = await useCases.stop(
        profileId: useCases.profileId,
        sessionId: sessionId,
      );
      if (mounted) {
        _showMessage(
          'Session saved · ${formatStudyDuration(result.detail.session.finalFocusedSeconds ?? 0)} focused',
        );
      }
      if (!result.platformAlertHandled && mounted) {
        _showMessage(
          'Session saved, but the break alert could not be cleared.',
        );
      }
    });
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _showMessage(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('active study session')) {
      return 'There is already a study session in progress.';
    }
    if (message.contains('Choose an open task')) {
      return 'That task is no longer available. Choose another task.';
    }
    return 'Could not update the study session. Please try again.';
  }
}
