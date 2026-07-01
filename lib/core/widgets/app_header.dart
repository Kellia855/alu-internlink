import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String? trailingAction;
  final VoidCallback? onTrailingAction;
  final bool showNotifications;
  final bool showAvatar;
  final bool showLogoAfterBack;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.onBack,
    this.trailingAction,
    this.onTrailingAction,
    this.showNotifications = true,
    this.showAvatar = true,
    this.showLogoAfterBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.textPrimary),
              onPressed: onBack ?? () => Navigator.maybePop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            if (showLogoAfterBack) const SizedBox(width: 4),
          ],
          if (!showBack)
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.cardGrey,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=12',
              ),
            ),
          if (!showBack) const SizedBox(width: 12),
          if (!showBack || showLogoAfterBack)
            const Text(
              'InternLink',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.accentPeach,
              ),
            ),
          const Spacer(),
          if (trailingAction != null)
            TextButton(
              onPressed: onTrailingAction,
              child: Text(
                trailingAction!,
                style: const TextStyle(
                  color: AppColors.accentPeach,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          if (showNotifications)
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
          if (showAvatar)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.cardGrey,
                backgroundImage: const NetworkImage(
                  'https://i.pravatar.cc/150?img=12',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
