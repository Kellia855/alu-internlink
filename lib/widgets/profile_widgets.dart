import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileStat extends StatelessWidget {
  const ProfileStat({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.grey),
        ),
      ],
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.navy).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? AppColors.navy),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? AppColors.charcoal,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
