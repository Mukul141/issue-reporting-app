// lib/features/report_history/widgets/report_list_item.dart
// Compact list tile for a report: category, date, status chip, and tap-to-view.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/report_model.dart';
import '../screens/report_details_screen.dart';

/// Displays a single report row with category, formatted date, and a colored
/// status chip; navigates to details on tap. [web:102]
class ReportListItem extends StatelessWidget {
  final Report report;

  const ReportListItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.blue),
        title: Text(report.category),
        // Uses intl DateFormat for locale-aware display. [web:198]
        subtitle: Text(DateFormat.yMMMd().format(report.timestamp.toDate())),
        // Material Chip conveys status with a background color. [web:200]
        trailing: Chip(
          label: Text(
            report.status,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _getStatusColor(report.status),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDetailsScreen(report: report),
            ),
          );
        },
      ),
    );
  }

  // ---- UI helpers ----

  /// Maps a status string to a representative color used by the trailing chip. [web:200]
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
