import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_flutter_advanced_nhom_4/screens/project_list_screen.dart';
import 'package:final_project_flutter_advanced_nhom_4/models/project.dart';

void main() {
  testWidgets('ProjectListScreen displays empty state correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(MaterialApp(home: ProjectListScreen()));

    // Verify empty state message is displayed
    expect(find.text('Chưa có project nào'), findsOneWidget);
  });

  testWidgets('ProjectListScreen shows add project dialog', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(MaterialApp(home: ProjectListScreen()));

    // Tap the add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Thêm Project Mới'), findsOneWidget);
    expect(
      find.byType(TextFormField),
      findsNWidgets(2),
    ); // Title and description fields
  });
}
