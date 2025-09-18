// lib/core/services/auth_service.dart
// Thin wrapper around FirebaseAuth for email/password auth and auth state access.

import 'package:firebase_auth/firebase_auth.dart';

/// Provides email/password authentication and auth state access using
/// FirebaseAuth in a Flutter app. [web:142]
class AuthService {
  /// Underlying Firebase authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- Accessors ----

  /// Currently signed-in user, or null if not authenticated. [web:142]
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes (login, logout, token refresh). [web:142]
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---- Auth flows ----

  /// Signs in with email and password; returns UserCredential on success,
  /// or null if a FirebaseAuthException occurs. [web:142]
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors as needed (e.code, e.message). [web:142]
      // Example codes: 'user-not-found', 'wrong-password', 'invalid-email'.
      // Keep UI-facing handling in the caller/UI layer.
      // Logging kept minimal to avoid leaking sensitive details.
      // print('Sign-in error: ${e.message}');
      return null;
    }
  }

  /// Creates an account with email and password; returns UserCredential on
  /// success, or null if a FirebaseAuthException occurs. [web:142]
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors as needed (e.code, e.message). [web:142]
      // Example codes: 'email-already-in-use', 'weak-password', 'invalid-email'.
      // print('Sign-up error: ${e.message}');
      return null;
    }
  }

  /// Signs out the current user. [web:142]
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
