import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Listen to the auth state changes stream
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // If the snapshot is still loading, show a progress indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the snapshot has data, the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // If the snapshot has no data, the user is logged out
        return const LoginScreen();
      },
    );
  }
}