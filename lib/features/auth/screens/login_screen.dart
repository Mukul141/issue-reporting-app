// lib/features/auth/screens/login_screen.dart
// Email/password login form with validation and a link to the sign-up flow.

import 'package:flutter/material.dart';
import 'package:issue_detection_app/features/auth/screens/signup_screen.dart';

import '../../../core/services/auth_service.dart';

/// Presents a simple email/password sign-in form and navigates to sign-up when
/// requested; on successful sign-in, the AuthWrapper reacts via authStateChanges. [web:163]
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ---- Form state ----

  /// Key used to validate and manage the form state. [web:172]
  final _formKey = GlobalKey<FormState>();

  /// Controllers for email and password input fields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Authentication service wrapper around FirebaseAuth.
  final _authService = AuthService();

  /// Indicates whether a sign-in is currently in progress.
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers to free resources when the widget is removed. [web:117]
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---- Actions ----

  /// Validates inputs, attempts sign-in, and shows a message on failure.
  /// On success, navigation is handled by the auth wrapper reacting to auth state. [web:163]
  Future<void> _signIn() async {
    // Validate form fields before attempting sign-in. [web:172]
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If sign-in fails, surface a brief error message.
      if (userCredential == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign in. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Stop the loading indicator; route changes are handled by AuthWrapper. [web:163]
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Enables validation across fields. [web:172]
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email field with basic non-empty validation. [web:172]
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password field with basic non-empty validation. [web:172]
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button shows a spinner while signing in. [web:172]
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
              ),

              // Link to the sign-up screen for new users.
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
