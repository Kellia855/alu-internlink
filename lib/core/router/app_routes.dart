import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/applications/screens/applications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/opportunities/screens/post_opportunity_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../features/opportunities/screens/company_profile_screen.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const applications = '/applications';
  static const profile = '/profile';
  static const discover = '/discover';
  static const notifications = '/notifications';
  static const postOpportunity = '/post-opportunity';
  static const companyProfile = '/company';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    applications: (context) => const ApplicationsScreen(),
    profile: (context) => const ProfileScreen(),
    discover: (context) => const ChatScreen(),
    notifications: (context) => const NotificationsScreen(),
    postOpportunity: (context) => const PostOpportunityScreen(),
    companyProfile: (context) => const CompanyProfileScreen(companyId: 'vertex'),
  };
}
