import 'package:flutter/material.dart';

import '../domain/entities/task.dart';
import '../features/reminders/presentation/reminder_settings_screen.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../features/tasks/presentation/task_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

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
  ];

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
        actions: [
          IconButton(
            tooltip: 'Reminder settings',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const ReminderSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: TaskListScreen(category: destination.category),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(builder: (_) => const TaskFormScreen()),
          );
        },
        tooltip: 'Create a task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.title,
            ),
        ],
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
  final TaskCategory category;
}
