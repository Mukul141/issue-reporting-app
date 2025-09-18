import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String userId;
  final String category;
  final String description;
  final List<String> imageUrls;
  final GeoPoint location;
  final Timestamp timestamp;
  final String status;
  final String department;

  Report({
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

  // A factory constructor to create a Report from a Firestore document
  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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

  // A method to convert a Report object into a Map for Firestore
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
}