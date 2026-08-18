import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_manager_app/main.dart';

void main() {
  testWidgets('shows task manager shell', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('New task'), findsOneWidget);
  });
}
