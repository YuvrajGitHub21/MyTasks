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
                      _ProgressHistoryItem(entry: entry),
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

class _ProgressHistoryItem extends StatelessWidget {
  const _ProgressHistoryItem({required this.entry});

  final ProgressEntry entry;

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
