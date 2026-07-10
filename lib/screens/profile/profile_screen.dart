import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/application_tile.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/profile_widgets.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';
import 'saved_opportunities_screen.dart';

/// Shared logout confirmation, used by both the settings bottom sheet and
/// the "Log out" row in the menu card below. A top-level function (rather
/// than a method) so both call sites can reach it without threading a
/// callback through every widget in between.
Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text('You can log back in anytime.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Log out', style: TextStyle(color: AppColors.rust)),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    // Signing out flips UserProvider's status to signedOut, which
    // AuthGate is listening to at the root of the app -- it swaps
    // straight back to LoginScreen automatically.
    await context.read<UserProvider>().signOut();
  }
}

/// Profile tab shared by both roles. The user document is already kept
/// live by [UserProvider] (it streams `users/{uid}`), so this screen just
/// watches that provider rather than issuing its own one-off fetch —
/// satisfying "fetch the current user's document from Firestore" while
/// avoiding a duplicate listener.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.navy),
                title: const Text('Edit profile'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: AppColors.navy),
                title: const Text('Help & support'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.rust),
                title: const Text('Log out', style: TextStyle(color: AppColors.rust)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmLogout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettingsSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.navy,
                  backgroundImage:
                      (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                  child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                      ? Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                _RoleBadge(profile: profile),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (profile.isStudent)
            _StudentStatsRow(profile: profile)
          else
            _StartupStatsRow(profile: profile),
          const SizedBox(height: 24),
          _MenuCard(profile: profile),
          const SizedBox(height: 24),
          if (profile.isStudent)
            _StudentSkillsSection(profile: profile)
          else
            _StartupOpportunitiesSection(profile: profile),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isStudent = profile.isStudent;
    final label = isStudent
        ? 'Student'
        : (profile.verified ? 'Verified startup' : 'Startup · Pending verification');
    final color =
        isStudent ? AppColors.blue : (profile.verified ? AppColors.success : AppColors.pending);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _StudentStatsRow extends StatelessWidget {
  const _StudentStatsRow({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<Application>>(
      stream: firestoreService.watchApplicationsForStudent(profile.uid),
      builder: (context, snapshot) {
        final apps = snapshot.data ?? const <Application>[];
        final accepted = apps.where((a) => a.status == ApplicationStatus.accepted).length;
        final pending = apps.where((a) => a.status == ApplicationStatus.pending).length;
        return _StatsCard(stats: [
          ProfileStat(value: '${apps.length}', label: 'Applications'),
          ProfileStat(value: '$pending', label: 'Pending'),
          ProfileStat(value: '$accepted', label: 'Accepted'),
        ]);
      },
    );
  }
}

class _StartupStatsRow extends StatelessWidget {
  const _StartupStatsRow({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<Opportunity>>(
      stream: firestoreService.watchOpportunitiesForStartup(profile.uid),
      builder: (context, oppSnap) {
        final opportunities = oppSnap.data ?? const <Opportunity>[];
        return StreamBuilder<List<Application>>(
          stream: firestoreService.watchApplicationsForStartup(profile.uid),
          builder: (context, appSnap) {
            final applications = appSnap.data ?? const <Application>[];
            return _StatsCard(stats: [
              ProfileStat(value: '${opportunities.length}', label: 'Posted'),
              ProfileStat(
                  value: '${opportunities.where((o) => o.verified).length}', label: 'Live'),
              ProfileStat(value: '${applications.length}', label: 'Applicants'),
            ]);
          },
        );
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});
  final List<Widget> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) Container(width: 1, height: 32, color: AppColors.lightGrey),
              Expanded(child: stats[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// The rounded card of chevron rows -- "My Profile", "Skills & Interests",
/// "Saved Opportunities", "Notifications", "Help & Support", "Logout" --
/// matching the reference design's profile menu.
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isStudent = profile.isStudent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            ProfileMenuTile(
              icon: Icons.person_outline_rounded,
              label: isStudent ? 'My profile' : 'Company profile',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            if (isStudent) ...[
              const Divider(height: 1),
              ProfileMenuTile(
                icon: Icons.emoji_objects_outlined,
                label: 'Skills & interests',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(focusSkills: true)),
                ),
              ),
              const Divider(height: 1),
              ProfileMenuTile(
                icon: Icons.bookmark_border_rounded,
                label: 'Saved opportunities',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedOpportunitiesScreen()),
                ),
              ),
            ],
            const Divider(height: 1),
            ProfileMenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            const Divider(height: 1),
            ProfileMenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & support',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              ),
            ),
            const Divider(height: 1),
            ProfileMenuTile(
              icon: Icons.logout_rounded,
              label: 'Log out',
              iconColor: AppColors.rust,
              labelColor: AppColors.rust,
              trailing: const SizedBox.shrink(),
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSkillsSection extends StatelessWidget {
  const _StudentSkillsSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
        ),
        const SizedBox(height: 10),
        profile.skills.isEmpty
            ? const Text(
                'No skills added yet — tap "Skills & interests" above to add some.',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.skills
                    .map(
                      (s) => Chip(
                        label: Text(s),
                        backgroundColor: AppColors.blue.withOpacity(0.08),
                        labelStyle: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
        const SizedBox(height: 24),
        const Text(
          'Recent applications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Application>>(
          stream: FirestoreService().watchApplicationsForStudent(profile.uid),
          builder: (context, snapshot) {
            final apps = (snapshot.data ?? const <Application>[]).take(3).toList();
            if (apps.isEmpty) {
              return const Text(
                "You haven't applied to anything yet.",
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              );
            }
            return Column(
              children: apps
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ApplicationTile(
                        application: a,
                        primaryLabel: a.opportunityTitle ?? 'Opportunity',
                        secondaryLabel: a.companyName ?? '',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StartupOpportunitiesSection extends StatelessWidget {
  const _StartupOpportunitiesSection({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              profile.verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
              size: 16,
              color: profile.verified ? AppColors.success : AppColors.pending,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                profile.verified
                    ? 'Verified — your postings are visible to students'
                    : 'Pending verification — postings stay hidden until approved',
                style: TextStyle(
                  fontSize: 12,
                  color: profile.verified ? AppColors.success : AppColors.pending,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Posted opportunities',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Opportunity>>(
          stream: FirestoreService().watchOpportunitiesForStartup(profile.uid),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <Opportunity>[];
            if (items.isEmpty) {
              return const Text(
                "You haven't posted any opportunities yet.",
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              );
            }
            return Column(
              children: items
                  .map((o) => OpportunityCard(opportunity: o, dense: true, showVerifiedBadge: true))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
