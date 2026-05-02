import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/core/constants/app_strings.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int selectedIndex = 0;
    if (location.startsWith('/completed')) {
      selectedIndex = 1;
    } else if (location.startsWith('/categories')) {
      selectedIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/todos');
            case 1:
              context.go('/completed');
            case 2:
              context.go('/categories');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outline_blank_rounded),
            selectedIcon: Icon(Icons.check_box_rounded),
            label: AppStrings.todos,
          ),
          NavigationDestination(
            icon: Icon(Icons.done_all_outlined),
            selectedIcon: Icon(Icons.done_all_rounded),
            label: AppStrings.completed,
          ),
          NavigationDestination(
            icon: Icon(Icons.label_outline_rounded),
            selectedIcon: Icon(Icons.label_rounded),
            label: AppStrings.categories,
          ),
        ],
      ),
    );
  }
}
