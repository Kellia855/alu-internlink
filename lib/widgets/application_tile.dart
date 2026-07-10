import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/application.dart';
import '../theme/app_colors.dart';
import 'status_badge.dart';

/// Row used both for a student's "my applications" list and a startup's
/// "applicants" list. Pass [primaryLabel]/[secondaryLabel] to control
/// which side of the relationship (opportunity vs. applicant) is shown.
class ApplicationTile extends StatelessWidget {
  const ApplicationTile({
    super.key,
    required this.application,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.actions,
  });

  final Application application;
  final String primaryLabel;
  final String secondaryLabel;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final dateStr = application.createdAt != null
        ? DateFormat('MMM d, yyyy').format(application.createdAt!)
        : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondaryLabel,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.grey),
                const SizedBox(width: 4),
                Text(
                  'Applied $dateStr',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
            if (actions != null) ...[
              const SizedBox(height: 12),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
