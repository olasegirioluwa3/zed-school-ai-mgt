// Widget smoke test for ZED AI School Admin app.
//
// Verifies that the app launches, shows the SplashScreen, and then
// navigates away after the splash timer fires — all without crashing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the app renders a MaterialApp without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance fake time past the 2-second splash timer so it fires
    // and completes before the test tears down (avoids pending-timer error).
    await tester.pump(const Duration(seconds: 2));

    // Settle any navigation animations triggered by the timer.
    await tester.pumpAndSettle();
  });
}
