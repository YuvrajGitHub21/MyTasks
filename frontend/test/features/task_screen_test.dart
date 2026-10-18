import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytasks/app/app_theme.dart';
import 'package:mytasks/app/task_use_case_providers.dart';
import 'package:mytasks/domain/entities/task.dart';
import 'package:mytasks/features/tasks/presentation/task_form_screen.dart';
import 'package:mytasks/features/tasks/presentation/task_list_screen.dart';

void main() {
  testWidgets('today list explains the empty state and offers task creation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskListProvider.overrideWith(
            (ref, category) => Stream<List<Task>>.value(const []),
          ),
        ],
        child: MaterialApp(
          theme: MyTasksTheme.light,
          home: const Scaffold(
            body: TaskListScreen(category: TaskCategory.current),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A clear page for today'), findsOneWidget);
    expect(find.text('Add a task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task form fits a larger accessible text scale', (tester) async {
    tester.view.physicalSize = const Size(432, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
        child: MaterialApp(
          theme: MyTasksTheme.light,
          home: const TaskFormScreen(),
        ),
      ),
    );
    expect(find.text('New task'), findsOneWidget);
    expect(find.text('Save task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
