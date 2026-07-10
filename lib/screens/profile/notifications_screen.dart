import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/time_ago.dart';

/// Read-only notifications list. Per firestore.rules, notifications are
/// written by trusted backend logic only (e.g. a Cloud Function reacting
/// to an application status change or a startup verification) — the
/// client never creates or edits them here.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<AppNotification>>(
              stream: firestoreService.watchNotifications(profile.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load notifications.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  );
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 40, color: AppColors.lightGrey),
                          SizedBox(height: 12),
                          Text(
                            "You're all caught up — nothing here yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.read
                            ? AppColors.white
                            : AppColors.maroon.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: n.read
                              ? AppColors.lightGrey.withOpacity(0.7)
                              : AppColors.maroon.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!n.read)
                            Container(
                              margin: const EdgeInsets.only(top: 5, right: 10),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.maroon,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  n.body,
                                  style: const TextStyle(
                                    color: AppColors.charcoal,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  timeAgo(n.createdAt),
                                  style: const TextStyle(
                                      color: AppColors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
