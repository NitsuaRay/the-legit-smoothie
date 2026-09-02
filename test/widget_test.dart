// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:the_legit_smoothie/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app with initialThemeMode provided
    await tester.pumpWidget(
      const TheLegitSmoothieApp(),
    );

    // Note: The counter test assertions from the default template can be removed 
    // or updated since your app displays the AuthGate / Login Screen instead of a counter.
  });
}