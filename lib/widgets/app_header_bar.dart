import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppHeaderBar extends StatelessWidget {
  const AppHeaderBar({
    super.key,
    required this.greeting,
    required this.subtitle,
    this.photoUrl,
    this.initials = '?',
    this.onNotificationsTap,
    this.onAvatarTap,
    this.unreadCount = 0,
  });

  final String greeting;
  final String subtitle;
  final String? photoUrl;
  final String initials;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onAvatarTap;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: Icons.notifications_none_rounded,
          badgeCount: unreadCount,
          onTap: onNotificationsTap,
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.navy,
            backgroundImage:
                (photoUrl != null && photoUrl!.isNotEmpty)
                    ? NetworkImage(photoUrl!)
                    : null,
            child: (photoUrl == null || photoUrl!.isEmpty)
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: AppColors.charcoal, size: 22),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.rust,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
