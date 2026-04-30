import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/main.dart';
import 'package:timetable/timetable_controller.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TimeTable(),
        child: const MainApp(),
      ),
    );

    // Verify that the app starts and shows the title.
    expect(find.text('My Schedule'), findsOneWidget);

    // Verify that the "Add Class" button is present.
    expect(find.text('Add Class'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
