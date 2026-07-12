import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:internlink/theme/app_theme.dart';


import 'package:internlink/screens/splash_screen.dart';


void main() {
  testWidgets('Splash screen renders InternLink branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );

    await tester.pump();

    expect(find.text('InternLink'), findsOneWidget);
  });
}

