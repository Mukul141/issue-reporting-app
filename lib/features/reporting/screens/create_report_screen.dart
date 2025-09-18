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

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  // --- NEW: Full Category-to-Department Mapping ---
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

  // State variables
  String? _selectedCategory;
  final List<File> _pickedImages = [];
  Position? _currentLocation;
  bool _isLoading = false;

  // Services
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationHelper.getCurrentLocation();
    setState(() {
      _currentLocation = position;
    });
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _currentLocation != null) {
      setState(() => _isLoading = true);

      try {
        List<String> imageUrls = [];
        final userId = _authService.currentUser!.uid;
        for (var imageFile in _pickedImages) {
          final url = await _storageService.uploadImage(imageFile, userId);
          imageUrls.add(url);
        }

        // --- NEW: Dynamic Department Mapping ---
        final department = _categoryDepartmentMap[_selectedCategory!] ?? 'Zonal Office';

        final newReport = Report(
          id: '',
          userId: userId,
          category: _selectedCategory!,
          description: _descriptionController.text.trim(),
          imageUrls: imageUrls,
          location: GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude),
          timestamp: Timestamp.now(),
          status: 'Submitted',
          department: department, // Use the dynamically mapped department
        );

        await _firestoreService.addReport(newReport);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and ensure location is captured.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Get category list from the map keys ---
    final categories = _categoryDepartmentMap.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Create New Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Issue Category'),
                // Use the new categories list
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. A separate Text widget for the label
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 2. The TextFormField with a hint and a border, but no label
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a detailed description of the issue...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    maxLines: 4,
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Add Images'),
              ),
              if (_pickedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _pickedImages.map((image) => Image.file(image, width: 100, height: 100, fit: BoxFit.cover)).toList(),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_currentLocation == null ? 'Fetching location...' : 'Location captured!')),
                      IconButton(onPressed: _getCurrentLocation, icon: const Icon(Icons.refresh))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitReport,
                child: const Text('Submit Report'),
              )
            ],
          ),
        ),
      ),
    );
  }
}