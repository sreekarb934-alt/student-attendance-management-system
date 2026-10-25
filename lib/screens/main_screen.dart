import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'placeholder_screen.dart';
import 'students_screen.dart';

/// The root scaffold of the application managing responsive navigation
/// between Dashboard, Students, Attendance, and Reports, while maintaining
/// the central in-memory student attendance state.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Central in-memory student collection for the application session.
  late List<Student> _students;

  @override
  void initState() {
    super.initState();
    _students = List.from(MockStudentData.students);
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _currentFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period';
  }

  /// Registers a newly validated student from the enrollment form.
  void _handleAddStudent(Student newStudent) {
    setState(() {
      _students.add(newStudent);
    });
  }

  /// Toggles an individual student's attendance between Present and Absent.
  void _handleToggleAttendance(String studentId) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        final current = _students[index];
        final isPresentNow = current.status == AttendanceStatus.present;
        final nextStatus =
            isPresentNow ? AttendanceStatus.absent : AttendanceStatus.present;

        _students[index] = current.copyWith(
          status: nextStatus,
          timeMarked: nextStatus == AttendanceStatus.present
              ? _currentFormattedTime()
              : null,
          clearTimeMarked: nextStatus == AttendanceStatus.absent,
        );
      }
    });
  }

  /// Sets an explicit attendance status for an individual student.
  void _handleUpdateStatus(String studentId, AttendanceStatus newStatus) {
    setState(() {
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        final current = _students[index];
        _students[index] = current.copyWith(
          status: newStatus,
          timeMarked: newStatus == AttendanceStatus.present
              ? _currentFormattedTime()
              : null,
          clearTimeMarked: newStatus == AttendanceStatus.absent,
        );
      }
    });
  }

  /// Sets the attendance status for all students simultaneously (Batch action).
  void _handleMarkAllStatus(AttendanceStatus newStatus) {
    setState(() {
      final formattedTime = _currentFormattedTime();
      _students = _students.map((student) {
        return student.copyWith(
          status: newStatus,
          timeMarked:
              newStatus == AttendanceStatus.present ? formattedTime : null,
          clearTimeMarked: newStatus == AttendanceStatus.absent,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens connected to the shared attendance state
    final List<Widget> screens = [
      DashboardScreen(
        students: _students,
        onNavigateToTab: _onDestinationSelected,
        onToggleAttendance: _handleToggleAttendance,
      ),
      StudentsScreen(
        students: _students,
        onAddStudent: _handleAddStudent,
        onToggleAttendance: _handleToggleAttendance,
      ),
      AttendanceScreen(
        students: _students,
        onUpdateStatus: _handleUpdateStatus,
        onMarkAllStatus: _handleMarkAllStatus,
      ),
      PlaceholderScreen(
        title: 'Attendance Reports',
        description:
            'Analyze monthly attendance percentages, export registers, and identify shortage lists.',
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
