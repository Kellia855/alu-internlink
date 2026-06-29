import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/applications/screens/applications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const applications = '/applications';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    applications: (context) => const ApplicationsScreen(),
    profile: (context) => const ProfileScreen(),
  };
}
