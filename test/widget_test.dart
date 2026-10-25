import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_attendance/main.dart';

void main() {
  testWidgets('Dashboard loads and renders attendance metrics and student records',
      (WidgetTester tester) async {
    // Set a realistic modern phone screen size (Pixel 7 / Galaxy S23)
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Build the StudentAttendanceApp
    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // Verify AppBar Title
    expect(find.text('Student Attendance'), findsOneWidget);

    // Verify Summary Cards
    expect(find.text('Total Students'), findsOneWidget);
    expect(find.text('Present Today'), findsOneWidget);
    expect(find.text('Absent Today'), findsOneWidget);

    // Verify Sample Student Data is present in the widget tree
    expect(find.text('Aarav Sharma'), findsOneWidget);
    expect(find.text('21A91A0501'), findsOneWidget);

    // Verify Navigation Destinations
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);

    // Tap on 'Students' navigation destination
    await tester.tap(find.text('Students'));
    await tester.pumpAndSettle();

    // Verify Placeholder Screen for Students
    expect(find.text('Student Directory'), findsOneWidget);

    // Return to Dashboard via button
    await tester.tap(find.text('Return to Dashboard'));
    await tester.pumpAndSettle();

    // Verify back on Dashboard
    expect(find.text('Total Students'), findsOneWidget);
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
    // Set desktop screen size
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const StudentAttendanceApp());
    await tester.pumpAndSettle();

    // NavigationRail should be rendered on wide screen
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
