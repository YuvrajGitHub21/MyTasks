import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/progress_use_case_providers.dart';
import '../../../domain/entities/progress_entry.dart';
import 'progress_entry_form.dart';

class ProgressHistorySection extends ConsumerWidget {
  const ProgressHistorySection({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(progressHistoryProvider(taskId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text('Progress history', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Log partial progress'),
        ),
        const SizedBox(height: 8),
        history.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text('Could not load progress history: $error'),
          data: (entries) => entries.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No progress has been logged yet.'),
                )
              : Column(
                  children: [
                    for (final entry in entries)
                      _ProgressHistoryItem(entry: entry, taskId: taskId),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ProgressEntryForm(taskId: taskId),
    );
  }
}

class _ProgressHistoryItem extends ConsumerWidget {
  const _ProgressHistoryItem({required this.entry, required this.taskId});

  final ProgressEntry entry;
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = switch (entry.method) {
      ProgressMethod.percent => '${entry.percentComplete}% complete',
      ProgressMethod.units =>
        '${entry.completedUnits} of ${entry.totalUnits} units complete',
      ProgressMethod.note => entry.note ?? 'Progress note',
    };
    final timestamp = entry.occurredAt.toLocal();
    final date =
        '${timestamp.year.toString().padLeft(4, '0')}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.history),
      title: Text(label),
      subtitle: Text(date),
      trailing: PopupMenuButton<String>(
        tooltip: 'Progress entry actions',
        onSelected: (action) {
          if (action == 'edit') _edit(context);
          if (action == 'delete') _delete(context, ref);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ProgressEntryForm(taskId: taskId, entry: entry),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this progress entry?'),
        content: const Text('This progress entry will be permanently removed.'),
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
      final deleteEntry = await ref.read(
        deleteProgressEntryUseCaseProvider.future,
      );
      final deleted = await deleteEntry(entry.id);
      if (!context.mounted || deleted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This progress entry was already deleted.'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete progress: $error')),
      );
    }
  }
}
