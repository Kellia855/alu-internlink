import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String? trailingAction;
  final VoidCallback? onTrailingAction;
  final bool showNotifications;
  final bool showAvatar;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.onBack,
    this.trailingAction,
    this.onTrailingAction,
    this.showNotifications = true,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBack ?? () => Navigator.maybePop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
          if (!showBack)
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentBlueLight,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=12',
              ),
            ),
          if (!showBack) const SizedBox(width: 12),
          const Text(
            'InternLink',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.maroon,
              fontFamily: 'Georgia',
            ),
          ),
          const Spacer(),
          if (trailingAction != null)
            TextButton(
              onPressed: onTrailingAction,
              child: Text(
                trailingAction!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
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
                backgroundColor: AppColors.accentBlueLight,
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
