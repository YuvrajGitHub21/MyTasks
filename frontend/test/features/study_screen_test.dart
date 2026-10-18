import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/app/study_session_use_case_providers.dart';
import 'package:mytasks/domain/entities/study_session.dart';
import 'package:mytasks/domain/entities/task.dart';
import 'package:mytasks/features/study/presentation/study_screen.dart';

void main() {
  testWidgets('shows the empty state and start action accessibly', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeStudySessionProvider.overrideWith(
            (ref) => Stream<StudySessionDetail?>.value(null),
          ),
          recentStudySessionsProvider.overrideWith(
            (ref) => Stream<List<StudySessionDetail>>.value(const []),
          ),
          studyAvailableTasksProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
        child: const MaterialApp(home: StudyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Focused today'), findsOneWidget);
    expect(find.text('Ready to focus?'), findsOneWidget);
    expect(find.text('Start studying'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('start screen remains laid out at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(432, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeStudySessionProvider.overrideWith(
            (ref) => Stream<StudySessionDetail?>.value(null),
          ),
          recentStudySessionsProvider.overrideWith(
            (ref) => Stream<List<StudySessionDetail>>.value(const []),
          ),
          studyAvailableTasksProvider.overrideWith(
            (ref) => const Stream.empty(),
          ),
        ],
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: const MaterialApp(home: StudyScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start studying'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task loading errors still let the user start without a task', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeStudySessionProvider.overrideWith(
            (ref) => Stream<StudySessionDetail?>.value(null),
          ),
          recentStudySessionsProvider.overrideWith(
            (ref) => Stream<List<StudySessionDetail>>.value(const []),
          ),
          studyAvailableTasksProvider.overrideWith(
            (ref) => Stream<List<Task>>.error(
              StateError('task storage unavailable'),
            ),
          ),
        ],
        child: const MaterialApp(home: StudyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start studying'));
    // The screen intentionally has a one-second stopwatch ticker and the
    // loading indicator animates, so advance the sheet animation directly.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Tasks could not be loaded.'), findsOneWidget);
    expect(find.text('Start without a task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
