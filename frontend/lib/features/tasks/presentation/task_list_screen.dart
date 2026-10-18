import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/rules/task_rules.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

/// A list screen derives its rows from repository data and today's IST date.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({required this.category, super.key});

  final TaskCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(taskListProvider(category));
    return taskList.when(
      loading: () => const _TaskListLoading(),
      error: (_, _) => _MessageState(
        icon: Icons.cloud_off_rounded,
        title: 'Your tasks could not be loaded',
        description: 'Your saved tasks are still on this device. Try again.',
        actionLabel: 'Try again',
        onAction: () => ref.invalidate(taskListProvider(category)),
      ),
      data: (tasks) {
        final today = TaskDate.todayInIst();
        if (tasks.isEmpty) {
          return _emptyState(context, today);
        }

        final plannedEffort = tasks.fold<int>(
          0,
          (total, task) => total + task.effortHundredths,
        );
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 164),
          children: [
            _ListOverview(
              category: category,
              taskCount: tasks.length,
              effortHundredths: plannedEffort,
              today: today,
            ),
            const SizedBox(height: 20),
            for (final task in tasks) ...[
              _TaskCard(
                task: task,
                today: today,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => TaskDetailScreen(taskId: task.id),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }

  Widget _emptyState(BuildContext context, TaskDate today) {
    final copy = switch (category) {
      TaskCategory.current || TaskCategory.overdue => (
        Icons.wb_sunny_rounded,
        'A clear page for today',
        'Add a task when you know what you want to work on.',
        'Add a task',
      ),
      TaskCategory.scheduled => (
        Icons.event_available_rounded,
        'Nothing planned ahead',
        'Schedule a task for a future day and it will appear here.',
        'Schedule a task',
      ),
      TaskCategory.completed => (
        Icons.task_alt_rounded,
        'Your wins will show up here',
        'Completed tasks stay here so you can look back at what you finished.',
        null,
      ),
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 164),
      children: [
        _ListOverview(
          category: category,
          today: today,
          taskCount: 0,
          effortHundredths: 0,
        ),
        const SizedBox(height: 24),
        _MessageState(
          icon: copy.$1,
          title: copy.$2,
          description: copy.$3,
          actionLabel: copy.$4,
          onAction: copy.$4 == null
              ? null
              : () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const TaskFormScreen(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ListOverview extends StatelessWidget {
  const _ListOverview({
    required this.taskCount,
    required this.effortHundredths,
    this.category,
    this.today,
  });

  final TaskCategory? category;
  final int taskCount;
  final int effortHundredths;
  final TaskDate? today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = category == TaskCategory.current;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'YOUR FOCUS' : 'YOUR TASKS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary == MyTasksColors.teal
                        ? MyTasksColors.tealInk
                        : theme.colorScheme.secondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isToday && today != null
                      ? _formatWeekdayDate(today!)
                      : _summaryFor(category),
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$taskCount ${taskCount == 1 ? 'task' : 'tasks'}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatEffort(effortHundredths)} h planned',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _summaryFor(TaskCategory? value) => switch (value) {
    TaskCategory.scheduled => 'Coming up',
    TaskCategory.completed => 'You did these',
    TaskCategory.overdue => 'Needs attention',
    _ => 'Today, one step at a time',
  };
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.today, this.onTap});

  final Task task;
  final TaskDate today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = TaskRules.classify(task, today);
    final overdue = category == TaskCategory.overdue;
    final isCurrent = category == TaskCategory.current;
    final statusColor = overdue
        ? theme.colorScheme.error
        : isCurrent
        ? _effortColor(task.effortHundredths)
        : theme.colorScheme.outlineVariant;
    final statusTextColor = overdue
        ? theme.colorScheme.error
        : isCurrent
        ? const Color(0xFF245B2A)
        : theme.colorScheme.onSurfaceVariant;
    final statusLabel = switch (category) {
      TaskCategory.overdue => 'Overdue',
      TaskCategory.current => 'Today',
      TaskCategory.scheduled => 'Scheduled',
      TaskCategory.completed => 'Completed',
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.topic,
                              style: theme.textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _EffortValue(
                            value: _formatEffort(task.effortHundredths),
                          ),
                        ],
                      ),
                      if (task.subtopic?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.subtopic!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusLabel(
                            label: statusLabel,
                            color: statusTextColor,
                            indicatorColor: statusColor,
                          ),
                          Text(
                            _dateLabel(task, category),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                  semanticLabel: 'Open task',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _effortColor(int hundredths) {
    final index = switch (TaskRules.effortBand(hundredths)) {
      EffortBand.level1 => 0,
      EffortBand.level2 => 1,
      EffortBand.level3 => 2,
      EffortBand.level4 => 3,
      EffortBand.level5 => 4,
    };
    return MyTasksColors.effortGreens[index];
  }

  String _dateLabel(Task task, TaskCategory category) => switch (category) {
    TaskCategory.overdue =>
      'Planned end ${_formatShortDate(task.plannedEndDate)}',
    TaskCategory.current => 'Due ${_formatShortDate(task.plannedEndDate)}',
    TaskCategory.scheduled =>
      '${_formatShortDate(task.startDate)} – ${_formatShortDate(task.plannedEndDate)}',
    TaskCategory.completed =>
      task.completedAt == null
          ? 'Finished'
          : 'Finished ${_formatDateTime(task.completedAt!)}',
  };
}

class _EffortValue extends StatelessWidget {
  const _EffortValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$value h', style: theme.textTheme.titleMedium),
        Text('EFFORT', style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({
    required this.label,
    required this.color,
    required this.indicatorColor,
  });

  final String label;
  final Color color;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 8, color: indicatorColor),
      const SizedBox(width: 6),
      Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    ],
  );
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF72584A).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 29,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaskListLoading extends StatelessWidget {
  const _TaskListLoading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading tasks',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 164),
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 136,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonLine(width: 174, height: 18),
                const SizedBox(height: 12),
                _SkeletonLine(width: 120, height: 13),
                const Spacer(),
                _SkeletonLine(width: 196, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    ),
  );
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

String _formatEffort(int hundredths) {
  final hours = hundredths ~/ 100;
  final fraction = hundredths % 100;
  return fraction == 0
      ? '$hours'
      : '$hours.${fraction.toString().padLeft(2, '0').replaceFirst(RegExp(r'0+$'), '')}';
}

String _formatShortDate(TaskDate date) =>
    '${date.day} ${_monthNames[date.month - 1]}';

String _formatWeekdayDate(TaskDate date) {
  final weekday = DateTime(date.year, date.month, date.day).weekday;
  return '${_weekdayNames[weekday - 1]}, ${_formatShortDate(date)}';
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${local.day} ${_monthNames[local.month - 1]}, $hour:$minute $period';
}

const _monthNames = <String>[
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

const _weekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
