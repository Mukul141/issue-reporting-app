// lib/features/auth/screens/signup_screen.dart
// Email/password sign-up form with confirmation and validation, then defers
// navigation to AuthWrapper via authStateChanges on success. [web:172]

import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

/// Presents a registration form for creating an account via email/password,
/// validates inputs (including password confirmation), and surfaces errors
/// via SnackBar; AuthWrapper handles post-auth navigation. [web:172]
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ---- Form state ----

  /// Key used to validate and manage the form state. [web:172]
  final _formKey = GlobalKey<FormState>();

  /// Controllers for email and password fields, including confirmation.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  /// Authentication service wrapper around FirebaseAuth.
  final _authService = AuthService();

  /// Indicates whether a sign-up is currently in progress.
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers to free resources when the widget is removed. [web:117]
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ---- Actions ----

  /// Validates inputs, attempts account creation, and shows a message on failure.
  /// On success, navigation is handled by the auth wrapper reacting to auth state. [web:172]
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign up. The email may already be in use.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Enables form-wide validation. [web:172]
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
                    return 'Please enter an email';
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
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm password must match the password field. [web:172]
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button shows a spinner while creating the account. [web:172]
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up'),
              ),

              // Return to the login screen for existing users.
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
