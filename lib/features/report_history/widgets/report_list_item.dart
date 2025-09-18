import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add 'intl' package to pubspec.yaml for date formatting
import '../../../core/models/report_model.dart';
import '../screens/report_details_screen.dart';

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
        subtitle: Text(DateFormat.yMMMd().format(report.timestamp.toDate())),
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