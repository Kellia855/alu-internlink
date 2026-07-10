import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../main_shell.dart';
import '../splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// Root traffic controller for the whole app.
///
/// - [AuthStatus.unknown]   -> SplashScreen (still resolving Firebase Auth)
/// - [AuthStatus.signedOut] -> LoginScreen or SignupScreen (toggle locally)
/// - [AuthStatus.signedIn]  -> MainShell, which reads `profile.role` to
///                             decide which four screens sit behind the
///                             shared AppRoutes.home/discover/applications/
///                             profile bottom-nav slots.
///
/// Keeping this as a single always-mounted widget (rather than routing via
/// named push/replace) means sign-in and sign-out are reflected instantly
/// everywhere, with no stale Navigator stack to unwind.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignup = false;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<UserProvider>().status;

    switch (status) {
      case AuthStatus.unknown:
        return const SplashScreen();
      case AuthStatus.signedOut:
        return _showSignup
            ? SignupScreen(onToggleMode: () => setState(() => _showSignup = false))
            : LoginScreen(onToggleMode: () => setState(() => _showSignup = true));
      case AuthStatus.signedIn:
        // Reset so a future logout always lands back on LoginScreen first.
        _showSignup = false;
        return const MainShell();
    }
  }
}
