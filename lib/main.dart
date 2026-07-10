import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InternLinkApp());
}

class InternLinkApp extends StatelessWidget {
  const InternLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'InternLink',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // AuthGate is the single source of truth for what's on screen;
        // `login`/`signup` are also registered as named routes so any
        // future deep link or explicit `Navigator.pushNamed` call still
        // resolves correctly.
        home: const AuthGate(),
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.signup: (_) => const SignupScreen(),
        },
      ),
    );
  }
}
