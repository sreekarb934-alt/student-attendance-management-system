import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_attendance/main.dart';

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

    // Verify Sample Student Data
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('21A91A0501'), findsOneWidget);

    // Verify Navigation Destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
  });

  testWidgets('Filter chips filter student list correctly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
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

    // Navigate to Students screen
    await tester.tap(find.text('Students'));
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
    await tester.tap(find.text('Students'));
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
    await tester.tap(find.text('Students'));
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
    await tester.tap(find.text('Dashboard'));
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
    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();

    expect(find.text('Mark Today\'s Attendance'), findsOneWidget);

    // Tap 'Mark All Present'
    await tester.tap(find.text('Mark All Present'));
    await tester.pumpAndSettle();

    // Verify confirmation snackbar
    expect(find.text('Marked all students as Present!'), findsOneWidget);

    // Navigate back to Dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    // Dashboard should now show all 10 present (0 absent)
    expect(find.text('10/10 (100%)'), findsOneWidget);
  });
}
