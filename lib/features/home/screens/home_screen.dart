// lib/features/home/screens/home_screen.dart
// User home dashboard: lists the current user's reports and links to creation.

import 'package:flutter/material.dart';

import '../../../core/models/report_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../reporting/screens/create_report_screen.dart';
import '../../report_history/widgets/report_list_item.dart';

/// Displays the signed-in user's reports in real time using a StreamBuilder,
/// and provides an action to create a new report. [web:169]
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await authService.signOut(),
          ),
        ],
      ),
      // Body shows a live list of reports via Firestore stream. [web:169]
      body: StreamBuilder<List<Report>>(
        stream: firestoreService.getReportsForUser(userId),
        builder: (context, snapshot) {
          // Show a spinner while waiting for the first stream event. [web:169]
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Surface any stream or query errors in a simple message. [web:169]
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Handle the empty state with a gentle prompt to add a report. [web:169]
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You have no reports yet. Tap + to add one!'),
            );
          }

          // Render the list of reports with a minimal, performant builder. [web:188]
          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ReportListItem(report: reports[index]);
            },
          );
        },
      ),
      // Floating action button to create a new report. [web:190]
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateReportScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Report a new issue',
      ),
    );
  }
}
