import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'Search opportunities...',
    this.onFilterTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.charcoal, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.35),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.tune_rounded, color: AppColors.white),
            ),
          ),
        ],
      ],
    );
  }
}
