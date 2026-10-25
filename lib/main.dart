import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

/// Entry point of the Student Attendance Management System.
/// Built for CS506PC – UI Design (Flutter Lab).
void main() {
  runApp(const StudentAttendanceApp());
}

/// Root widget configuring the Material 3 application theme and initial route.
class StudentAttendanceApp extends StatelessWidget {
  const StudentAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}
