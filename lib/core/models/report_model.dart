// lib/core/models/report_model.dart
// Data model for issue reports stored in Firestore. Represents a single
// citizen-submitted report with metadata, media, and routing fields.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable model representing a single urban issue report as stored in
/// Cloud Firestore, including author, categorization, media, location,
/// lifecycle status, and routing department. [web:119]
class Report {
  /// Firestore document ID (auto-generated on create).
  final String id;

  /// UID of the user who created the report.
  final String userId;

  /// Category label (e.g., 'Pothole / Damaged Road').
  final String category;

  /// Free-text description detailing the issue.
  final String description;

  /// Public download URLs for uploaded images.
  final List<String> imageUrls;

  /// Geographic coordinates where the issue was observed.
  final GeoPoint location;

  /// Client-submitted timestamp of report creation.
  final Timestamp timestamp;

  /// Current lifecycle state (e.g., 'Submitted', 'In Progress', 'Resolved').
  final String status;

  /// Routing/owning department assigned to this report.
  final String department;

  /// Creates a new Report instance with all required fields.
  const Report({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.imageUrls,
    required this.location,
    required this.timestamp,
    required this.status,
    required this.department,
  });

  // ---- Serialization ----

  /// Converts this Report into a Firestore-ready map for writes. [web:119]
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'description': description,
      'imageUrls': imageUrls,
      'location': location,
      'timestamp': timestamp,
      'status': status,
      'department': department,
    };
  }

  /// Reconstructs a Report from a typed Firestore document snapshot. The
  /// document ID is taken from [doc.id]; missing fields fall back to safe
  /// defaults for display resilience. [web:119][web:130]
  factory Report.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data()!;
    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      location: data['location'] ?? const GeoPoint(0, 0),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      status: data['status'] ?? 'Submitted',
      department: data['department'] ?? 'Unassigned',
    );
  }
}
