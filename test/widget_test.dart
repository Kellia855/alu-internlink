import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alu_internlink/core/theme/app_theme.dart';
import 'package:alu_internlink/features/home/screens/home_screen.dart';

void main() {
  testWidgets('Home screen renders InternLink branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );

    expect(find.text('InternLink'), findsOneWidget);
    expect(find.text('New Opportunities'), findsOneWidget);
  });
}
