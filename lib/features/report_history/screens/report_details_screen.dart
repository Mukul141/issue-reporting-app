import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/report_model.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Report report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(report.category),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip
            Chip(
              label: Text(
                report.status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: _getStatusColor(report.status),
            ),
            const SizedBox(height: 16),

            // Image Section
            _buildSectionTitle('Images'),
            if (report.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(report.imageUrls[index]),
                    );
                  },
                ),
              )
            else
              const Text('No images were attached to this report.'),

            const SizedBox(height: 24),

            // Details Section
            _buildSectionTitle('Details'),
            _buildDetailRow('Reported on:', DateFormat.yMMMd().add_jm().format(report.timestamp.toDate())),
            _buildDetailRow('Description:', report.description),
            _buildDetailRow('Location:', '${report.location.latitude.toStringAsFixed(5)}, ${report.location.longitude.toStringAsFixed(5)}'),
            _buildDetailRow('Assigned To:', report.department),
          ],
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }
}