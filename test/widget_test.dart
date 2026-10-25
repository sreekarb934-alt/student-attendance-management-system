import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_attendance/main.dart';
import 'package:student_attendance/models/student.dart';
import 'package:student_attendance/screens/reports_screen.dart';

void main() {
  testWidgets('Dashboard loads and renders attendance metrics and student records',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Verify AppBar Title
    expect(find.text('Student Attendance'), findsOneWidget);

    // Verify Summary Cards
    expect(find.text('Total Students'), findsOneWidget);
    expect(find.text('Present Today'), findsOneWidget);
    expect(find.text('Absent Today'), findsOneWidget);

    // Verify Navigation Destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Students'), findsWidgets);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Reports'), findsWidgets);

    // Scroll down to reveal student records in the ListView
    await tester.drag(find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();

    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('21A91A0501'), findsOneWidget);
  });

  testWidgets('Filter chips filter student list correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Scroll to student list
    await tester.drag(find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();

    // Initially both present and absent students are visible
    expect(find.text('Aarav Sharma'), findsOneWidget); // Present student
    expect(find.text('Bhavya Patel'), findsOneWidget); // Absent student

    // Filter by Absent
    await tester.tap(find.text('Absent (3)'));
    await tester.pumpAndSettle();

    // Now Aarav (Present) is not shown, but Bhavya (Absent) is
    expect(find.text('Aarav Sharma'), findsNothing);
    expect(find.text('Bhavya Patel'), findsOneWidget);

    // Filter by Present
    await tester.tap(find.text('Present (7)'));
    await tester.pumpAndSettle();

    // Now Aarav (Present) is shown, Bhavya (Absent) is not
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('Bhavya Patel'), findsNothing);
  });

  testWidgets('Wide screen displays NavigationRail and hides NavigationBar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Adding student via form validates required fields',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Students screen via bottom navigation destination
    await tester.tap(find.byIcon(Icons.people_outline_rounded));
    await tester.pumpAndSettle();

    // Tap on FloatingActionButton to open Add Student dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add New Student'), findsOneWidget);

    // Try submitting without filling fields
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Add Student');
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Verify validation errors are shown
    expect(find.text('Please enter the student\'s name'), findsOneWidget);
    expect(find.text('Please enter the roll number'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Duplicate roll number prevention displays validation error',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Students screen
    await tester.tap(find.byIcon(Icons.people_outline_rounded));
    await tester.pumpAndSettle();

    // Open Add Student dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill valid name but duplicate roll number ('21A91A0501' is Aarav Sharma's)
    await tester.enterText(find.byType(TextFormField).at(0), 'Rohan Bansal');
    await tester.enterText(find.byType(TextFormField).at(1), '21A91A0501');

    // Submit
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Add Student');
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Check duplicate roll number validation error
    expect(find.text('A student with roll number "21A91A0501" already exists'),
        findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Adding student succeeds and updates Dashboard statistics',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Students screen
    await tester.tap(find.byIcon(Icons.people_outline_rounded));
    await tester.pumpAndSettle();

    // Open Add Student dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill valid new student data
    await tester.enterText(find.byType(TextFormField).at(0), 'Rohan Bansal');
    await tester.enterText(find.byType(TextFormField).at(1), '21A91A0511');

    // Submit
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Add Student');
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Check student now in student roster
    expect(find.text('Rohan Bansal'), findsOneWidget);
    expect(find.text('21A91A0511'), findsOneWidget);

    // Navigate back to Dashboard
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    // Total should now be 11, Present should be 8
    expect(find.text('11'), findsWidgets);
    expect(find.text('8'), findsWidgets);
    expect(find.text('All (11)'), findsOneWidget);
    expect(find.text('Present (8)'), findsOneWidget);
  });

  testWidgets(
      'Attendance screen marking updates Present/Absent states and reflects in Dashboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Attendance screen
    await tester.tap(find.byIcon(Icons.how_to_reg_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Mark Today\'s Attendance'), findsOneWidget);

    // Tap 'Mark All Present'
    await tester.tap(find.text('Mark All Present'));
    await tester.pumpAndSettle();

    // Verify confirmation snackbar
    expect(find.text('Marked all students as Present!'), findsOneWidget);

    // Navigate back to Dashboard
    await tester.tap(find.byIcon(Icons.dashboard_outlined));
    await tester.pumpAndSettle();

    // Dashboard should now show all 10 present (0 absent)
    expect(find.text('10/10 (100%)'), findsOneWidget);
  });

  testWidgets(
      'Reports screen displays metrics, department summaries, and student breakdowns',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Reports screen via NavigationBar
    await tester.tap(find.byIcon(Icons.assessment_outlined));
    await tester.pumpAndSettle();

    // Verify Header and Notice
    expect(find.text('Attendance Analytics & Reports'), findsOneWidget);
    expect(find.text('Session Snapshot'), findsOneWidget);

    // Verify Summary Cards in Reports
    expect(find.text('Total Enrolled'), findsOneWidget);
    expect(find.text('Overall Attendance Ratio'), findsOneWidget);
    expect(find.text('Department-Wise Attendance'), findsOneWidget);
    expect(find.text('CSE - Section A'), findsOneWidget);

    // Scroll to reveal student breakdown section
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Student-Wise Attendance Register'), findsOneWidget);
    expect(find.text('Aarav Sharma'), findsOneWidget);
  });

  testWidgets(
      'Reports screen reflects live attendance updates when attendance changes',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Navigate to Attendance and Mark All Absent
    await tester.tap(find.byIcon(Icons.how_to_reg_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark All Absent'));
    await tester.pumpAndSettle();

    // Navigate to Reports screen
    await tester.tap(find.byIcon(Icons.assessment_outlined));
    await tester.pumpAndSettle();

    // Now Attendance Rate in Reports should show 0.0%
    expect(find.text('0.0%'), findsWidgets);
    expect(find.text('Absent Today'), findsOneWidget);
    expect(find.text('Attendance Shortage (<75%)'), findsOneWidget);
  });

  testWidgets(
      'Reports screen handles empty student list safely without division by zero',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Render ReportsScreen directly with an empty student list
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsScreen(students: []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Metrics should display 0 and 0.0% safely
    expect(find.text('Total Enrolled'), findsOneWidget);
    expect(find.text('0.0%'), findsOneWidget);
    expect(find.text('No Department Data Available'), findsOneWidget);
    expect(find.text('No Data'), findsWidgets);
  });

  testWidgets(
      'Department breakdown groups students correctly across multiple departments',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const testStudents = [
      Student(
        id: '1',
        name: 'Student CSE 1',
        rollNumber: 'CSE01',
        department: 'CSE - Section A',
        status: AttendanceStatus.present,
      ),
      Student(
        id: '2',
        name: 'Student CSE 2',
        rollNumber: 'CSE02',
        department: 'CSE - Section A',
        status: AttendanceStatus.absent,
      ),
      Student(
        id: '3',
        name: 'Student ECE 1',
        rollNumber: 'ECE01',
        department: 'ECE - Section A',
        status: AttendanceStatus.present,
      ),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportsScreen(students: testStudents),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both departments should be rendered
    expect(find.text('2 Departments'), findsOneWidget);
    expect(find.text('CSE - Section A'), findsOneWidget);
    expect(find.text('ECE - Section A'), findsOneWidget);

    // CSE: 1 present of 2 (50.0%)
    expect(find.text('Present: 1 of 2'), findsOneWidget);
    expect(find.text('50.0%'), findsOneWidget);

    // ECE: 1 present of 1 (100.0%)
    expect(find.text('Present: 1 of 1'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
  });
}
