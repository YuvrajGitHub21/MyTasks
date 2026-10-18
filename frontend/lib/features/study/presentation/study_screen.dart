import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/study_session_use_case_providers.dart';
import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/study_session.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/rules/study_time_calculator.dart';
import '../../tasks/presentation/task_form_screen.dart';

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
        _TodayFocusSummary(seconds: total),
        const SizedBox(height: 20),
        active.when(
          data: (detail) => detail == null
              ? _StartStudyCard(
                  onStart: _chooseAndStart,
                  busy: _busy || _choosingTask,
                  loading: _choosingTask,
                )
              : _ActiveStudyCard(
                  detail: detail,
                  nowUtc: _nowUtc,
                  busy: _busy,
                  onBreak: _chooseBreak,
                  onResume: () => _resume(detail.session.id),
                  onStop: () => _stop(detail.session.id),
                ),
          loading: () => const _StudyLoadingCard(),
          error: (_, _) => const _StudyErrorCard(),
        ),
        const SizedBox(height: 28),
        Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        history.when(
          data: (sessions) => sessions.isEmpty
              ? const _HistoryEmptyCard()
              : Column(
                  children: [
                    for (final detail in sessions.take(12))
                      _StudyHistoryCard(detail: detail, nowUtc: _nowUtc),
                  ],
                ),
          loading: () => const _StudyLoadingCard(),
          error: (_, _) => const _StudyErrorCard(),
        ),
      ],
    );
  }

  Future<void> _chooseAndStart() async {
    if (_busy || _choosingTask) return;
    setState(() => _choosingTask = true);
    try {
      final choice = await showModalBottomSheet<_StartChoice>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => const _TaskChoiceSheet(),
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
      builder: (context) => const _BreakChoiceSheet(),
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
          'Session saved · ${_formatDuration(result.detail.session.finalFocusedSeconds ?? 0)} focused',
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

class _TodayFocusSummary extends StatelessWidget {
  const _TodayFocusSummary({required this.seconds});

  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories_rounded, color: colors.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focused today',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  seconds == null
                      ? 'Loading your total…'
                      : _formatDuration(seconds!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onSecondaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartStudyCard extends StatelessWidget {
  const _StartStudyCard({
    required this.onStart,
    required this.busy,
    required this.loading,
  });

  final VoidCallback onStart;
  final bool busy;
  final bool loading;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Ready to focus?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Start a session, add a break when you need one, and stop when you are done.',
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: busy ? null : onStart,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(loading ? 'Loading tasks…' : 'Start studying'),
          ),
        ],
      ),
    ),
  );
}

class _TaskChoiceSheet extends ConsumerWidget {
  const _TaskChoiceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(studyAvailableTasksProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.72,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'What are you studying?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Link this session to an open task, or start without one.'),
              const SizedBox(height: 12),
              tasks.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Tasks could not be loaded. You can create a task or start without linking one.',
                  ),
                ),
                data: (availableTasks) => Column(
                  children: [
                    for (final task in availableTasks)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.task_alt_rounded),
                        title: Text(
                          task.topic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${task.startDate} · due ${task.plannedEndDate}',
                        ),
                        onTap: () => Navigator.pop(
                          context,
                          _StartChoice(taskId: task.id),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_calendar_outlined),
                title: const Text('Create a task'),
                onTap: () => Navigator.pop(
                  context,
                  const _StartChoice(createNewTask: true),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Start without a task'),
                onTap: () => Navigator.pop(context, const _StartChoice()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartChoice {
  const _StartChoice({this.taskId, this.createNewTask = false});

  final String? taskId;
  final bool createNewTask;
}

class _ActiveStudyCard extends StatelessWidget {
  const _ActiveStudyCard({
    required this.detail,
    required this.nowUtc,
    required this.busy,
    required this.onBreak,
    required this.onResume,
    required this.onStop,
  });

  final StudySessionDetail detail;
  final DateTime nowUtc;
  final bool busy;
  final ValueChanged<String> onBreak;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final session = detail.session;
    final isOnBreak = session.status == StudySessionStatus.onBreak;
    final activeBreak = detail.activeBreak;
    final elapsed = isOnBreak && activeBreak != null
        ? activeBreak.plannedEndAtUtc
              .difference(nowUtc)
              .inSeconds
              .clamp(0, 86400)
        : session.focusedSecondsAt(nowUtc);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnBreak
                        ? const Color(0xFFFFD166)
                        : const Color(0xFF3C966B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOnBreak ? 'ON BREAK' : 'FOCUSING',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(elapsed),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontFeatures: const [],
              ),
              semanticsLabel: isOnBreak
                  ? 'Break time remaining: ${_formatDuration(elapsed)}'
                  : 'Focused time: ${_formatDuration(elapsed)}',
            ),
            const SizedBox(height: 8),
            _StudyTaskCaption(taskId: session.taskId),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (isOnBreak)
                  FilledButton.icon(
                    onPressed: busy ? null : onResume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume study'),
                  )
                else
                  FilledButton.tonalIcon(
                    onPressed: busy ? null : () => onBreak(session.id),
                    icon: const Icon(Icons.coffee_rounded),
                    label: const Text('Take a break'),
                  ),
                OutlinedButton.icon(
                  onPressed: busy ? null : onStop,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop session'),
                ),
              ],
            ),
            if (isOnBreak && activeBreak != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Break ends at ${_formatClock(activeBreak.plannedEndAtUtc)}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BreakChoiceSheet extends StatefulWidget {
  const _BreakChoiceSheet();

  @override
  State<_BreakChoiceSheet> createState() => _BreakChoiceSheetState();
}

class _BreakChoiceSheetState extends State<_BreakChoiceSheet> {
  final _customController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: AnimatedPadding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      duration: const Duration(milliseconds: 180),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a break',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text('Focused time pauses until you choose Resume study.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                children: [
                  for (final minutes in [10, 20])
                    ActionChip(
                      label: Text('$minutes minutes'),
                      onPressed: () => Navigator.pop(context, minutes),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _customController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Custom minutes (1–240)',
                  errorText: _error,
                  suffixIcon: IconButton(
                    tooltip: 'Start custom break',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: _submit,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _submit() {
    final minutes = int.tryParse(_customController.text.trim());
    if (minutes == null || minutes < 1 || minutes > 240) {
      setState(() => _error = 'Enter a whole number from 1 to 240.');
      return;
    }
    Navigator.pop(context, minutes);
  }
}

class _StudyHistoryCard extends ConsumerWidget {
  const _StudyHistoryCard({required this.detail, required this.nowUtc});

  final StudySessionDetail detail;
  final DateTime nowUtc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = detail.session;
    final taskId = session.taskId;
    final task = taskId == null
        ? null
        : ref.watch(taskDetailsProvider(taskId)).asData?.value;
    final focused = session.focusedSecondsAt(nowUtc);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.auto_stories_rounded),
        ),
        title: Text(
          task?.topic ?? (taskId == null ? 'Personal study' : 'Linked task'),
        ),
        subtitle: Text(
          '${_formatDate(session.startedAtUtc)}\nFocus ${_formatDuration(focused)} · '
          'Break ${_formatDuration(detail.breakSecondsAt(nowUtc))}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _StudyTaskCaption extends ConsumerWidget {
  const _StudyTaskCaption({required this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taskId == null) return const Text('No task linked');
    final task = ref.watch(taskDetailsProvider(taskId!)).asData?.value;
    return Text(task?.topic ?? 'Linked task');
  }
}

class _HistoryEmptyCard extends StatelessWidget {
  const _HistoryEmptyCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text('Your completed study sessions will appear here.'),
    ),
  );
}

class _StudyLoadingCard extends StatelessWidget {
  const _StudyLoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: SizedBox(
      height: 112,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _StudyErrorCard extends StatelessWidget {
  const _StudyErrorCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'Study sessions could not be opened. Restart the app and try again.',
      ),
    ),
  );
}

String _formatDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final hours = safe ~/ 3600;
  final minutes = (safe % 3600) ~/ 60;
  final remainder = safe % 60;
  return hours > 0
      ? '${hours}h ${minutes.toString().padLeft(2, '0')}m'
      : '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}

String _formatClock(DateTime utc) {
  final ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  return '$hour:${ist.minute.toString().padLeft(2, '0')} ${ist.hour < 12 ? 'AM' : 'PM'}';
}

String _formatDate(DateTime utc) {
  final ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  return '${months[ist.month - 1]} ${ist.day}, $hour:${ist.minute.toString().padLeft(2, '0')} ${ist.hour < 12 ? 'AM' : 'PM'}';
}
