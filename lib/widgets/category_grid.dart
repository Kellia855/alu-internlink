import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../theme/app_colors.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.onCategoryTap});

  final ValueChanged<String> onCategoryTap;

  static const _icons = {
    OpportunityCategory.design: Icons.palette_outlined,
    OpportunityCategory.engineering: Icons.code_rounded,
    OpportunityCategory.marketing: Icons.campaign_outlined,
    OpportunityCategory.data: Icons.bar_chart_rounded,
    OpportunityCategory.other: Icons.apps_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: OpportunityCategory.all.map((category) {
        return _CategoryItem(
          label: category,
          icon: _icons[category] ?? Icons.apps_rounded,
          onTap: () => onCategoryTap(category),
        );
      }).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.navy, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.charcoal),
          ),
        ],
      ),
    );
  }
}
