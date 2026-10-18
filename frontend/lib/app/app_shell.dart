import 'package:flutter/material.dart';

import '../domain/entities/task.dart';
import '../features/reminders/presentation/reminder_settings_screen.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../features/tasks/presentation/task_list_screen.dart';
import '../features/study/presentation/study_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const _pageGutter = 24.0;

  static const _destinations = <_TaskDestination>[
    _TaskDestination(
      title: 'Today',
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      category: TaskCategory.current,
    ),
    _TaskDestination(
      title: 'Later',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      category: TaskCategory.scheduled,
    ),
    _TaskDestination(
      title: 'Completed',
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      category: TaskCategory.completed,
    ),
    _TaskDestination(
      title: 'Study',
      icon: Icons.auto_stories_outlined,
      selectedIcon: Icons.auto_stories_rounded,
      category: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: _pageGutter,
        title: Text(
          destination.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: _pageGutter),
            child: Center(
              child: IconButton.filledTonal(
                tooltip: 'Reminder settings',
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const ReminderSettingsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer,
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
          ),
        ],
      ),
      body: destination.category == null
          ? const StudyScreen()
          : TaskListScreen(category: destination.category!),
      floatingActionButton: destination.category == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const TaskFormScreen(),
                  ),
                );
              },
              tooltip: 'Create a task',
              child: const Icon(Icons.add_rounded),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_pageGutter, 4, _pageGutter, 12),
          child: Container(
            height: 76,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF72584A).withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var index = 0; index < _destinations.length; index++)
                  Expanded(
                    child: _NavigationDestinationButton(
                      destination: _destinations[index],
                      selected: index == _selectedIndex,
                      onPressed: () => setState(() => _selectedIndex = index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationDestinationButton extends StatelessWidget {
  const _NavigationDestinationButton({
    required this.destination,
    required this.selected,
    required this.onPressed,
  });

  final _TaskDestination destination;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.title,
      child: Tooltip(
        message: destination.title,
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(32),
            child: SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 25,
                    color: selected
                        ? colors.onPrimaryContainer
                        : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDestination {
  const _TaskDestination({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.category,
  });

  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final TaskCategory? category;
}
