import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_colors.dart';
import 'time_ago.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.trailing,
    this.showVerifiedBadge = false,
    this.dense = false,
    this.isSaved = false,
    this.onToggleSave,
  });

  final Opportunity opportunity;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showVerifiedBadge;

  /// Compact "recent opportunities" list style: logo, title, company,
  /// a meta line (commitment • location), and a bookmark toggle — no
  /// description snippet.
  final bool dense;

  /// Whether this opportunity is in the current user's saved list.
  /// Pass null-safe defaults from screens that don't support saving
  /// (e.g. a startup viewing its own postings) by leaving [onToggleSave]
  /// null — the bookmark button hides itself in that case.
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    if (dense) return _buildDense(context);
    return _buildFull(context);
  }

  Widget _buildDense(BuildContext context) {
    final metaParts = [
      if (opportunity.commitment.isNotEmpty) opportunity.commitment,
      if (opportunity.location != null && opportunity.location!.isNotEmpty)
        opportunity.location!,
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGrey.withOpacity(0.7)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoFallback(category: opportunity.category),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opportunity.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    opportunity.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (metaParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.grey, fontSize: 11.5),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onToggleSave != null)
              _BookmarkButton(saved: isSaved, onTap: onToggleSave!)
            else
              trailing ??
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogoFallback(category: opportunity.category),

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            opportunity.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.charcoal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onToggleSave != null)
                          _BookmarkButton(saved: isSaved, onTap: onToggleSave!),
                      ],
                    ),
                    if (showVerifiedBadge && !opportunity.verified) ...[
                      const SizedBox(height: 4),
                      const _PendingChip(),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      opportunity.companyName,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (opportunity.location != null &&
                        opportunity.location!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.grey),
                          const SizedBox(width: 2),
                          Text(
                            opportunity.location!,
                            style: const TextStyle(
                                color: AppColors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      opportunity.description,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (opportunity.skillsRequired.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: opportunity.skillsRequired
                            .take(3)
                            .map((s) => _SkillChip(label: s))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule,
                            size: 13, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'Posted ${timeAgo(opportunity.createdAt)}',
                          style: const TextStyle(
                              color: AppColors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 12),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({required this.saved, required this.onTap});
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: 20,
          color: saved ? AppColors.maroon : AppColors.grey,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}



class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.category});

  final String category;

  IconData _iconForCategory(String c) {
    switch (c) {
      case OpportunityCategory.design:
        return Icons.palette_outlined;
      case OpportunityCategory.engineering:
        return Icons.build_outlined;
      case OpportunityCategory.marketing:
        return Icons.campaign_outlined;
      case OpportunityCategory.data:
        return Icons.storage_outlined;
      case OpportunityCategory.other:
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconForCategory(category),
      color: AppColors.navy,
      size: 28,
    );
  }
}


class _PendingChip extends StatelessWidget {
  const _PendingChip();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.pending.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Pending review',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.pending,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
