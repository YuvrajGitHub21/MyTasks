import 'package:flutter/material.dart';

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
      emptyTitle: 'No tasks for today',
      emptyDescription: 'Tasks scheduled for today will appear here.',
    ),
    _TaskDestination(
      title: 'Later',
      icon: Icons.event_outlined,
      selectedIcon: Icons.event,
      emptyTitle: 'Nothing scheduled yet',
      emptyDescription: 'Tasks with a future start date will appear here.',
    ),
    _TaskDestination(
      title: 'Completed',
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      emptyTitle: 'No completed tasks yet',
      emptyDescription: 'Tasks you complete will be kept here.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final destination = _destinations[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(destination.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                destination.selectedIcon,
                size: 48,
                semanticLabel: destination.title,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                destination.emptyTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                destination.emptyDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
    required this.emptyTitle,
    required this.emptyDescription,
  });

  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final String emptyTitle;
  final String emptyDescription;
}
