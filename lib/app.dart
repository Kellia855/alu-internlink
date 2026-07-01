import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_routes.dart';

class InternLinkApp extends StatelessWidget {
  const InternLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternLink',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
