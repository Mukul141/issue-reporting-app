// lib/features/reporting/screens/create_report_screen.dart
// Form to submit a new issue report: category, description, photos, and location.
// Uses form validation, image_picker for multiple images, and Geolocator for GPS. [web:172][web:219][web:151]

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/report_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/location_helper.dart';

/// Creates a new report by collecting structured inputs, uploading images to
/// storage, and persisting the report to Firestore. [web:172]
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // ---- Form state ----

  /// Key used to validate and manage the report form. [web:172]
  final _formKey = GlobalKey<FormState>();

  /// Description text controller.
  final _descriptionController = TextEditingController();

  // ---- Configuration ----

  /// Category → Department mapping used to auto-assign owning department.
  final Map<String, String> _categoryDepartmentMap = {
    'Pothole / Damaged Road': 'Public Works Department (PWD)',
    'Damaged Public Building': 'Public Works Department (PWD)',
    'Fallen Tree / Debris on Road': 'Parks and Horticulture Department',
    'Garbage Overflow / Uncleaned Area': 'Solid Waste Management Department',
    'Blocked Drain / Water Logging': 'Water & Sewerage Department',
    'Missing Manhole / Drain Cover': 'Water & Sewerage Department',
    'Streetlight Not Working': 'Electrical Department',
    'Damaged Traffic Signal': 'Traffic Police / Electrical Department',
  };

  // ---- Local UI state ----

  String? _selectedCategory;
  final List<File> _pickedImages = [];
  Position? _currentLocation;
  bool _isLoading = false;

  // ---- Services ----

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // ---- Lifecycle ----

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ---- Actions ----

  /// Opens the gallery to select multiple images and appends them to state. [web:219]
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  /// Acquires the current GPS location after permission checks. [web:151]
  Future<void> _getCurrentLocation() async {
    final position = await LocationHelper.getCurrentLocation();
    setState(() {
      _currentLocation = position;
    });
  }

  /// Validates inputs, uploads images, builds the Report, and saves it to Firestore.
  /// Surfaces success or failure via SnackBars and navigates back on success. [web:172]
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _currentLocation != null) {
      setState(() => _isLoading = true);

      try {
        // 1) Upload images (if any) and collect download URLs. [web:219]
        final userId = _authService.currentUser!.uid;
        final imageUrls = <String>[];
        for (final imageFile in _pickedImages) {
          final url = await _storageService.uploadImage(imageFile, userId);
          imageUrls.add(url);
        }

        // 2) Resolve department from category.
        final department =
            _categoryDepartmentMap[_selectedCategory!] ?? 'Zonal Office';

        // 3) Build report model.
        final newReport = Report(
          id: '',
          userId: userId,
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          imageUrls: imageUrls,
          location: GeoPoint(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
          timestamp: Timestamp.now(),
          status: 'Submitted',
          department: department,
        );

        // 4) Persist to Firestore and notify. [web:172]
        await _firestoreService.addReport(newReport);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text('Please fill all fields and ensure location is captured.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    final categories = _categoryDepartmentMap.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Enables validation. [web:172]
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Issue Category'),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                )
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedCategory = newValue),
                validator: (value) =>
                value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Description (label + TextFormField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText:
                      'Enter a detailed description of the issue...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: 4,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Images
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Images'),
              ),
              if (_pickedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _pickedImages
                      .map(
                        (image) => Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      .toList(),
                ),
              const SizedBox(height: 16),

              // Location
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_currentLocation == null
                            ? 'Fetching location...'
                            : 'Location captured!'),
                      ),
                      IconButton(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
