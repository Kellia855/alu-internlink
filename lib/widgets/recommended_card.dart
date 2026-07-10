import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_colors.dart';
import 'time_ago.dart';

/// The gradient "hero" card on the student Home screen — matches the
/// reference design's featured card, restyled to the maroon → rust dark
/// red gradient instead of purple.
class RecommendedCard extends StatelessWidget {
  const RecommendedCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.isSaved = false,
    this.onToggleSave,
  });

  final Opportunity opportunity;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final tags = [
      if (opportunity.category.isNotEmpty) opportunity.category,
      ...opportunity.skillsRequired.take(2),
    ].take(3).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.white, size: 17),
                ),
                if (onToggleSave != null)
                  InkWell(
                    onTap: onToggleSave,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: AppColors.white,
                        size: 17,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              opportunity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              opportunity.companyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.85),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.schedule, size: 13, color: AppColors.white),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    opportunity.commitment.isNotEmpty
                        ? opportunity.commitment
                        : 'Flexible hours',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 10.5),
                  ),
                ),
                Text(
                  'Posted ${timeAgo(opportunity.createdAt)}',
                  style: TextStyle(
                      color: AppColors.white.withOpacity(0.7), fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
