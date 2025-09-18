import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper function to define the custom sort order
  int _getSortPriority(String status) {
    switch (status) {
      case 'In Progress':
        return 0; // Highest priority
      case 'Submitted':
        return 1;
      case 'Resolved':
        return 2;
      default:
        return 3; // Lowest priority (e.g., 'Pending Sync')
    }
  }

  Stream<List<Report>> getReportsForUser(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true) // Primary sort by date from Firebase
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => Report.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      // Apply our custom sort logic to the list
      reports.sort((a, b) {
        final priorityA = _getSortPriority(a.status);
        final priorityB = _getSortPriority(b.status);
        // Compare by status priority. If priorities are the same,
        // the original date sorting from the query is maintained.
        return priorityA.compareTo(priorityB);
      });

      return reports;
    });
  }

  // Other methods like addReport and saveUserToken remain the same
  Future<void> addReport(Report report) async {
    // ... your existing addReport code ...
  }

  Future<void> saveUserToken(String userId, String token) async {
    // ... your existing saveUserToken code ...
  }
}