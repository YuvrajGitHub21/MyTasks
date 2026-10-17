import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/lifecycle_use_case_providers.dart';
import '../../../domain/entities/lifecycle_event.dart';

class LifecycleHistorySection extends ConsumerWidget {
  const LifecycleHistorySection({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(taskLifecycleHistoryProvider(taskId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Completion history',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        history.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) =>
              Text('Could not load completion history: $error'),
          data: (events) => events.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No completion or reopening events yet.'),
                )
              : Column(
                  children: [
                    for (final event in events)
                      _LifecycleHistoryItem(event: event),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LifecycleHistoryItem extends StatelessWidget {
  const _LifecycleHistoryItem({required this.event});

  final LifecycleEvent event;

  @override
  Widget build(BuildContext context) {
    final completed = event.type == LifecycleEventType.completed;
    final timestamp = event.occurredAt.toLocal();
    final date =
        '${timestamp.year.toString().padLeft(4, '0')}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(completed ? Icons.check_circle_outline : Icons.undo),
      title: Text(completed ? 'Marked complete' : 'Reopened'),
      subtitle: Text(date),
    );
  }
}
