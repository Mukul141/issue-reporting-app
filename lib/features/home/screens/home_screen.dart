import 'package:flutter/material.dart';
import '../../../core/models/report_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../reporting/screens/create_report_screen.dart';
import '../../report_history/widgets/report_list_item.dart';

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
      body: StreamBuilder<List<Report>>(
        // Listen to the stream of reports for the current user
        stream: firestoreService.getReportsForUser(userId),
        builder: (context, snapshot) {
          // 1. While loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. If there's an error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // 3. If there's no data or the list is empty
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You have no reports yet. Tap + to add one!'),
            );
          }

          // 4. If we have data, display it in a list
          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              return ReportListItem(report: reports[index]);
            },
          );
        },
      ),
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