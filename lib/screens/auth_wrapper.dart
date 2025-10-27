import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

/// AuthWrapper checks authentication status and redirects accordingly
/// If authenticated -> HomeScreen
/// If not authenticated -> LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Show loading while checking auth
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Redirect based on auth status
    return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
