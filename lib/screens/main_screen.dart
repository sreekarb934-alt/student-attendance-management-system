import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'placeholder_screen.dart';

/// The root scaffold of the application managing responsive navigation
/// between Dashboard, Students, Attendance, and Reports.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens corresponding to navigation destinations
    final List<Widget> screens = [
      const DashboardScreen(),
      PlaceholderScreen(
        title: 'Student Directory',
        description:
            'View, register, and organize students by department, year, and section.',
        icon: Icons.people_alt_rounded,
        onReturnHome: () => _onDestinationSelected(0),
      ),
      PlaceholderScreen(
        title: 'Mark Attendance',
        description:
            'Conduct real-time class roll calls with batch check-ins and period tracking.',
        icon: Icons.how_to_reg_rounded,
        onReturnHome: () => _onDestinationSelected(0),
      ),
      PlaceholderScreen(
        title: 'Attendance Reports',
        description:
            'Analyze attendance percentages, export monthly registers, and identify shortages.',
        icon: Icons.assessment_rounded,
        onReturnHome: () => _onDestinationSelected(0),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Screen is considered wide if width is 720px or greater
        final isWideScreen = constraints.maxWidth >= 720;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student Attendance'),
            actions: [
              // Academic Session Chip (shown on wide screen)
              if (isWideScreen)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.class_outlined, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'CSE-A (2026)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications will be available in future updates.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: isWideScreen
              ? Row(
                  children: [
                    // Desktop / Tablet NavigationRail
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _onDestinationSelected,
                      labelType: NavigationRailLabelType.all,
                      leading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryLightBlue,
                          child: Icon(
                            Icons.school,
                            size: 20,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.dashboard_outlined),
                          selectedIcon: Icon(Icons.dashboard_rounded),
                          label: Text('Dashboard'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.people_outline_rounded),
                          selectedIcon: Icon(Icons.people_rounded),
                          label: Text('Students'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.how_to_reg_outlined),
                          selectedIcon: Icon(Icons.how_to_reg_rounded),
                          label: Text('Attendance'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.assessment_outlined),
                          selectedIcon: Icon(Icons.assessment_rounded),
                          label: Text('Reports'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    // Expanded screen content
                    Expanded(
                      child: screens[_selectedIndex],
                    ),
                  ],
                )
              : screens[_selectedIndex],
          // Mobile NavigationBar (shown only when not wide screen)
          bottomNavigationBar: isWideScreen
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_outline_rounded),
                      selectedIcon: Icon(Icons.people_rounded),
                      label: 'Students',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.how_to_reg_outlined),
                      selectedIcon: Icon(Icons.how_to_reg_rounded),
                      label: 'Attendance',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.assessment_outlined),
                      selectedIcon: Icon(Icons.assessment_rounded),
                      label: 'Reports',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
