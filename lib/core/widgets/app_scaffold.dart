import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final bool showBottomNav;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    this.showBottomNav = true,
  });

  void _onTap(BuildContext context, int idx) {
    if (idx == currentIndex) return;
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/applications');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/discover');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => _onTap(context, i),
            )
          : null,
    );
  }
}
