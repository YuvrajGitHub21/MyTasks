import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/lifecycle_use_case_providers.dart';
import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/task.dart';

class LifecycleControls extends ConsumerWidget {
  const LifecycleControls({
    required this.taskId,
    required this.status,
    super.key,
  });

  final String taskId;
  final TaskStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = status == TaskStatus.completed;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: completed
          ? OutlinedButton.icon(
              onPressed: () => _confirmTransition(context, ref),
              icon: const Icon(Icons.undo),
              label: const Text('Reopen task'),
            )
          : FilledButton.icon(
              onPressed: () => _confirmTransition(context, ref),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark fully complete'),
            ),
    );
  }

  Future<void> _confirmTransition(BuildContext context, WidgetRef ref) async {
    final reopening = status == TaskStatus.completed;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(reopening ? 'Reopen this task?' : 'Complete this task?'),
        content: Text(
          reopening
              ? 'The task will return to your open task list. Its previous '
                    'completion event will remain in history.'
              : 'This marks the task fully complete. Partial progress entries '
                    'remain separate from this completion event.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(reopening ? 'Reopen' : 'Complete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final actions = await ref.read(taskLifecycleActionsProvider.future);
      final changed = reopening
          ? await actions.reopenTask(taskId)
          : await actions.completeTask(taskId);
      if (!context.mounted) return;
      if (changed) {
        ref.invalidate(taskDetailsProvider(taskId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The task could not be updated.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update the task: $error')),
      );
    }
  }
}
