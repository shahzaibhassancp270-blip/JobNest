// lib/widgets/status_badge.dart
import 'package:flutter/material.dart';
import 'package:jobnest/core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'Saved': return Colors.grey;
      case 'Applied': return AppColors.primary;
      case 'Interview': return AppColors.accent;
      case 'Offer': return AppColors.secondary;
      case 'Rejected': return AppColors.error;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
