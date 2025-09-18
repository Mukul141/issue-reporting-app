// lib/main.dart
// Application entry point: initializes Firebase and starts the Flutter app.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/auth/screens/auth_wrapper.dart';
import 'firebase_options.dart';

/// Boots the Flutter framework, initializes Firebase with generated options,
/// then runs the root widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UrbanIssuesApp());
}

/// Root widget for the app.
/// Provides global theme and sets the authenticated flow wrapper as home.
class UrbanIssuesApp extends StatelessWidget {
  const UrbanIssuesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Issue Reporter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(), // Decides between Login and Home based on auth state.
    );
  }
}
