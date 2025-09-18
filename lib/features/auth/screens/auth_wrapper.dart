// lib/features/auth/screens/auth_wrapper.dart
// Decides which screen to show based on FirebaseAuth auth state.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';

/// Routes to HomeScreen when a user is signed in, otherwise shows LoginScreen,
/// by listening to FirebaseAuth's authStateChanges stream. [web:164]
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Subscribe to authentication state changes (signed-in user or null). [web:164]
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show a lightweight loading indicator while waiting for first value. [web:169]
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // When a user exists, navigate to the authenticated home flow. [web:164]
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise, show the unauthenticated login flow. [web:164]
        return const LoginScreen();
      },
    );
  }
}
