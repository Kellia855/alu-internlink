import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Horizontal segmented filter, e.g. "All / Pending / Accepted / Rejected".
class StatusFilterTabs extends StatelessWidget {
  const StatusFilterTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              backgroundColor: AppColors.lightGrey.withOpacity(0.4),
              selectedColor: AppColors.maroon,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.charcoal,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
