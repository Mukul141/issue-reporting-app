// lib/core/services/storage_service.dart
// Firebase Storage helper for uploading media and returning download URLs.

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Provides simple file upload utilities backed by Firebase Storage
/// for use in Flutter apps. [web:35]
class StorageService {
  /// Shared Firebase Storage instance.
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---- Uploads ----

  /// Uploads an image [file] under `reports/` with a user-scoped name and
  /// returns its public download URL. Throws on failure. [web:35]
  Future<String> uploadImage(File file, String userId) async {
    try {
      // Generate a unique filename with user ID and timestamp for traceability. [web:117]
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create a storage reference inside the 'reports' prefix. [web:35]
      final ref = _storage.ref().child('reports/$fileName');

      // Upload the file and await completion; Firebase creates paths as needed. [web:35]
      final uploadTask = await ref.putFile(file);

      // Resolve a downloadable URL for client rendering or persistence. [web:35]
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Keep logs minimal; rethrow so UI layer can handle errors. [web:102]
      // print('Error uploading image: $e');
      rethrow;
    }
  }
}
