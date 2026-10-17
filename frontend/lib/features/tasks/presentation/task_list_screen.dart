import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/rules/task_rules.dart';
import '../../../app/task_use_case_providers.dart';

/// A list screen derives its rows from repository data and today's IST date.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({required this.category, super.key});

  final TaskCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskList = ref.watch(taskListProvider(category));
    return taskList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _MessageState(
        icon: Icons.error_outline,
        title: 'Could not open tasks',
        description: error.toString(),
      ),
      data: (tasks) {
        final today = TaskDate.todayInIst();
        if (tasks.isEmpty) {
          final emptyCopy = switch (category) {
            TaskCategory.current => (
              Icons.today_outlined,
              'No tasks for today',
              'Tasks starting today or earlier will appear here.',
            ),
            TaskCategory.scheduled => (
              Icons.event_outlined,
              'Nothing scheduled yet',
              'Tasks with a future start date will appear here.',
            ),
            TaskCategory.completed => (
              Icons.check_circle_outline,
              'No completed tasks yet',
              'Tasks you complete will be kept here.',
            ),
            TaskCategory.overdue => (
              Icons.today_outlined,
              'No tasks for today',
              'Tasks starting today or earlier will appear here.',
            ),
          };
          return _MessageState(
            icon: emptyCopy.$1,
            title: emptyCopy.$2,
            description: emptyCopy.$3,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: tasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) =>
              _TaskCard(task: tasks[index], today: today),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.today});

  final Task task;
  final TaskDate today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = TaskRules.classify(task, today);
    final overdue = category == TaskCategory.overdue;
    final color = overdue
        ? theme.colorScheme.error
        : category == TaskCategory.current
        ? _effortColor(theme.colorScheme, task.effortHundredths)
        : theme.colorScheme.outlineVariant;
    final effort = _formatEffort(task.effortHundredths);
    final status = switch (category) {
      TaskCategory.overdue => 'Overdue',
      TaskCategory.current => 'Due ${task.plannedEndDate}',
      TaskCategory.scheduled => '${task.startDate} – ${task.plannedEndDate}',
      TaskCategory.completed => 'Completed',
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 8, color: color),
            Expanded(
              child: ListTile(
                title: Text(task.topic),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.subtopic?.isNotEmpty ?? false)
                      Text(task.subtopic!),
                    const SizedBox(height: 4),
                    Text('$status  ·  Estimated effort $effort h'),
                  ],
                ),
                isThreeLine: task.subtopic?.isNotEmpty ?? false,
                leading: Icon(
                  category == TaskCategory.completed
                      ? Icons.check_circle_outline
                      : Icons.task_alt,
                  color: color,
                  semanticLabel: category == TaskCategory.completed
                      ? 'Completed'
                      : overdue
                      ? 'Overdue'
                      : 'Open task',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _effortColor(ColorScheme colors, int hundredths) {
    final base = colors.primary;
    final tint = colors.primaryContainer;
    final opacity = switch (TaskRules.effortBand(hundredths)) {
      EffortBand.level1 => 0.30,
      EffortBand.level2 => 0.45,
      EffortBand.level3 => 0.60,
      EffortBand.level4 => 0.75,
      EffortBand.level5 => 0.90,
    };
    return Color.lerp(tint, base, opacity)!;
  }

  String _formatEffort(int hundredths) {
    final hours = hundredths ~/ 100;
    final fraction = hundredths % 100;
    return fraction == 0
        ? '$hours'
        : '$hours.${fraction.toString().padLeft(2, '0').replaceFirst(RegExp(r'0+$'), '')}';
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
