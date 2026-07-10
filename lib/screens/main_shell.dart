import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

import 'profile/profile_screen.dart';
import 'startup/startup_applications_screen.dart';
import 'startup/startup_home_screen.dart';
import 'startup/startup_post_opportunity_screen.dart';
import 'student/student_applications_screen.dart';
import 'student/student_discover_screen.dart';
import 'student/student_home_screen.dart';

/// The single shell both roles live in. It owns one bottom navigation bar
/// with four fixed slots -- [AppRoutes.home], [AppRoutes.discover],
/// [AppRoutes.applications], [AppRoutes.profile] -- and simply swaps in a
/// different screen widget per slot depending on the signed-in user's role.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void jumpToTab(String routeTabId) {
    final i = AppRoutes.tabOrder.indexOf(routeTabId);
    if (i != -1) setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isStudent = profile.role == UserRole.student;

    final screens = isStudent
        ? const [
            StudentHomeScreen(),
            StudentDiscoverScreen(),
            StudentApplicationsScreen(),
            ProfileScreen(),
          ]
        : const [
            StartupHomeScreen(),
            StartupPostOpportunityScreen(),
            StartupApplicationsScreen(),
            ProfileScreen(),
          ];

    final navItems = isStudent
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Applicants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: IndexedStack(index: _index, children: screens),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          items: navItems,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

/// Helper so nested screens (e.g. a "View all" button on the dashboard)
/// can jump the parent shell to a different tab without prop-drilling.
void jumpToShellTab(BuildContext context, String routeTabId) {
  context.findAncestorStateOfType<MainShellState>()?.jumpToTab(routeTabId);
}
