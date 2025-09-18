import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart'; // Import the model we just created

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Method to add a new report
  Future<void> addReport(Report report) async {
    try {
      // Access the 'reports' collection and add a new document
      // using the toMap() method from our Report model
      await _db.collection('reports').add(report.toMap());
    } catch (e) {
      // It's good practice to handle potential errors
      print('Error adding report: $e');
      rethrow; // Rethrow the error to be handled by the UI
    }
  }

  // 2. Method to get a real-time stream of reports for a user
  Stream<List<Report>> getReportsForUser(String userId) {
    return _db
        .collection('reports')
    // Query the collection to find documents where 'userId' matches
        .where('userId', isEqualTo: userId)
    // Order the reports by timestamp to show the newest first
        .orderBy('timestamp', descending: true)
    // snapshots() returns a Stream for real-time updates
        .snapshots()
        .map((snapshot) {
      // For each document snapshot, convert it to a Report object
      return snapshot.docs
          .map((doc) => Report.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    });
  }
}