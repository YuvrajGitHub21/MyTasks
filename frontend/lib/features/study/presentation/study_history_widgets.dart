import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/task_use_case_providers.dart';
import '../../../domain/entities/study_session.dart';
import 'study_session_widgets.dart';

class StudyHistoryCard extends ConsumerWidget {
  const StudyHistoryCard({
    super.key,
    required this.detail,
    required this.nowUtc,
  });

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
          '${formatStudyDate(session.startedAtUtc)}\nFocus ${formatStudyDuration(focused)} · '
          'Break ${formatStudyDuration(detail.breakSecondsAt(nowUtc))}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text('Your completed study sessions will appear here.'),
    ),
  );
}

class StudyLoadingCard extends StatelessWidget {
  const StudyLoadingCard({super.key});

  @override
  Widget build(BuildContext context) => const Card(
    child: SizedBox(
      height: 112,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class StudyErrorCard extends StatelessWidget {
  const StudyErrorCard({super.key});

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
