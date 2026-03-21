import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/class_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/workout_provider.dart';
import 'theme/app_theme.dart';
import 'navigation/main_navigation.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const CseeApp());
}

class CseeApp extends StatelessWidget {
  const CseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
      ],
      child: MaterialApp(
        title: 'CSEE GYM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}
