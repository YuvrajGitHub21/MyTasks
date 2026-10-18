import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/study_session_use_case_providers.dart';
import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/study_session.dart';

class TodayFocusSummary extends StatelessWidget {
  const TodayFocusSummary({super.key, required this.seconds});

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
                      : formatStudyDuration(seconds!),
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

class StartStudyCard extends StatelessWidget {
  const StartStudyCard({
    super.key,
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

class TaskChoiceSheet extends ConsumerWidget {
  const TaskChoiceSheet({super.key});

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
                          StartChoice(taskId: task.id),
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
                  const StartChoice(createNewTask: true),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Start without a task'),
                onTap: () => Navigator.pop(context, const StartChoice()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartChoice {
  const StartChoice({this.taskId, this.createNewTask = false});

  final String? taskId;
  final bool createNewTask;
}

class ActiveStudyCard extends StatelessWidget {
  const ActiveStudyCard({
    super.key,
    required this.detail,
    required this.nowUtc,
    required this.busy,
    required this.onFocus,
    required this.onBreak,
    required this.onResume,
    required this.onStop,
  });

  final StudySessionDetail detail;
  final DateTime nowUtc;
  final bool busy;
  final VoidCallback onFocus;
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
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: onFocus,
                  tooltip: 'Open full-screen study focus',
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formatStudyDuration(elapsed),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontFeatures: const [],
              ),
              semanticsLabel: isOnBreak
                  ? 'Break time remaining: ${formatStudyDuration(elapsed)}'
                  : 'Focused time: ${formatStudyDuration(elapsed)}',
            ),
            const SizedBox(height: 8),
            StudyTaskCaption(taskId: session.taskId),
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
                  'Break ends at ${formatStudyClock(activeBreak.plannedEndAtUtc)}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BreakChoiceSheet extends StatefulWidget {
  const BreakChoiceSheet({super.key});

  @override
  State<BreakChoiceSheet> createState() => _BreakChoiceSheetState();
}

class StudyTaskCaption extends ConsumerWidget {
  const StudyTaskCaption({super.key, required this.taskId});

  final String? taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taskId == null) return const Text('No task linked');
    final task = ref.watch(taskDetailsProvider(taskId!)).asData?.value;
    return Text(task?.topic ?? 'Linked task');
  }
}

class _BreakChoiceSheetState extends State<BreakChoiceSheet> {
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

String formatStudyDuration(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final hours = safe ~/ 3600;
  final minutes = (safe % 3600) ~/ 60;
  final remainder = safe % 60;
  return hours > 0
      ? '${hours}h ${minutes.toString().padLeft(2, '0')}m'
      : '${minutes}m ${remainder.toString().padLeft(2, '0')}s';
}

String formatStudyClock(DateTime utc) {
  final ist = utc.toUtc().add(const Duration(hours: 5, minutes: 30));
  final hour = ist.hour % 12 == 0 ? 12 : ist.hour % 12;
  return '$hour:${ist.minute.toString().padLeft(2, '0')} ${ist.hour < 12 ? 'AM' : 'PM'}';
}

String formatStudyDate(DateTime utc) {
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
