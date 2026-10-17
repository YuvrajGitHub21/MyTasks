import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/rules/task_rules.dart';
import 'progress_history_section.dart';
import 'task_form_screen.dart';

/// Task details and task-level actions.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskDetailsProvider(taskId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task details'),
        actions: [
          IconButton(
            tooltip: 'Edit task',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => TaskFormScreen(taskId: taskId),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: task.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DetailsMessage(
          icon: Icons.error_outline,
          message: 'Could not load this task: $error',
        ),
        data: (value) => value == null
            ? const _DetailsMessage(
                icon: Icons.search_off_outlined,
                message: 'This task is no longer available.',
              )
            : _TaskDetails(task: value, taskId: taskId),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this task?'),
        content: const Text(
          'This permanently deletes the task and all of its progress and '
          'completion history from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final deleteTask = await ref.read(deleteTaskUseCaseProvider.future);
      final deleted = await deleteTask(taskId);
      if (!context.mounted) return;
      if (deleted) {
        ref.invalidate(taskDetailsProvider(taskId));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This task was already deleted.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete this task: $error')),
      );
    }
  }
}

class _TaskDetails extends StatelessWidget {
  const _TaskDetails({required this.task, required this.taskId});

  final Task task;
  final String taskId;

  @override
  Widget build(BuildContext context) {
    final today = TaskDate.todayInIst();
    final category = TaskRules.classify(task, today);
    final status = switch (category) {
      TaskCategory.current => 'Current',
      TaskCategory.scheduled => 'Scheduled',
      TaskCategory.overdue => 'Overdue',
      TaskCategory.completed => 'Completed',
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(task.topic, style: Theme.of(context).textTheme.headlineSmall),
        if (task.subtopic?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(task.subtopic!, style: Theme.of(context).textTheme.titleMedium),
        ],
        const SizedBox(height: 20),
        _DetailRow(label: 'Status', value: status),
        _DetailRow(label: 'Start date', value: task.startDate.toString()),
        _DetailRow(
          label: 'Planned end date',
          value: task.plannedEndDate.toString(),
        ),
        if (task.maximumEndDate case final maximumEndDate?)
          _DetailRow(
            label: 'Maximum end date',
            value: maximumEndDate.toString(),
          ),
        _DetailRow(
          label: 'Estimated effort',
          value: '${_formatEffort(task.effortHundredths)} hours',
        ),
        if (task.completedAt case final completedAt?)
          _DetailRow(
            label: 'Completed',
            value: completedAt.toLocal().toString(),
          ),
        if (task.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 20),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(task.description!),
        ],
        ProgressHistorySection(taskId: taskId),
      ],
    );
  }

  String _formatEffort(int hundredths) {
    final hours = hundredths ~/ 100;
    final fraction = hundredths % 100;
    return fraction == 0
        ? '$hours'
        : '$hours.${fraction.toString().padLeft(2, '0').replaceFirst(RegExp(r'0+$'), '')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 152,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _DetailsMessage extends StatelessWidget {
  const _DetailsMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
