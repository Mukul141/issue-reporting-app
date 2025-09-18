// lib/core/services/firestore_service.dart
// Firestore data access for reports: read streams, create writes, and helpers.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

/// Provides Firestore-backed operations for reading and writing report data,
/// exposing real-time streams and simple create methods. [web:41]
class FirestoreService {
  /// Shared Firestore instance.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- Sorting helpers ----

  /// Returns a numeric priority used to sort reports by workflow status,
  /// placing active items before resolved ones. [web:117]
  int _getSortPriority(String status) {
    switch (status) {
      case 'In Progress':
        return 0; // Highest priority
      case 'Submitted':
        return 1;
      case 'Resolved':
        return 2;
      default:
        return 3; // Lowest priority (e.g., unknown or pending sync)
    }
  }

  // ---- Queries & streams ----

  /// Streams all reports for a given user, ordered by timestamp (desc) from
  /// Firestore, then locally ordered by status priority for display. [web:41]
  Stream<List<Report>> getReportsForUser(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final reports = snapshot.docs
          .map((doc) => Report.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      ))
          .toList();

      // Apply custom status priority after primary date ordering.
      reports.sort((a, b) {
        final priorityA = _getSortPriority(a.status);
        final priorityB = _getSortPriority(b.status);
        return priorityA.compareTo(priorityB);
      });

      return reports;
    });
  }

  // ---- Mutations ----

  /// Adds a new report document to the 'reports' collection using model
  /// serialization, rethrowing on errors for UI handling. [web:41]
  Future<void> addReport(Report report) async {
    try {
      await _db.collection('reports').add(report.toMap());
    } catch (e) {
      // Keep logs minimal; surface errors to caller.
      // Consider using a logger in production.
      // print('Error adding report: $e');
      rethrow;
    }
  }

  /// Upserts an FCM token for a user document; implement as needed to enable
  /// notifications and downstream messaging workflows. [web:41]
  Future<void> saveUserToken(String userId, String token) async {
    // TODO: Implement user token persistence if notifications are enabled.
    // Example:
    // await _db.collection('users').doc(userId).set({
    //   'fcmToken': token,
    //   'updatedAt': FieldValue.serverTimestamp(),
    // }, SetOptions(merge: true));
  }
}
