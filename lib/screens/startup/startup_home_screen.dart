import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application.dart';
import '../../models/opportunity.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_header_bar.dart';
import '../../widgets/application_tile.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/profile_widgets.dart';
import '../../widgets/section_header.dart';
import '../main_shell.dart';

/// Startup's Home tab: a dashboard summarizing what they've posted and
/// who has applied, with quick stats up top.
class StartupHomeScreen extends StatelessWidget {
  const StartupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final firestoreService = FirestoreService();

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          AppHeaderBar(
            greeting: 'Hello, ${profile.companyName}!',
            subtitle: profile.verified
                ? 'Here is your recruiting overview.'
                : 'Your account is pending verification.',
            photoUrl: profile.photoUrl,
            initials: profile.companyName.isNotEmpty
                ? profile.companyName[0].toUpperCase()
                : '?',
          ),
          if (!profile.verified) ...[
            const SizedBox(height: 16),
            _VerificationBanner(),
          ],
          const SizedBox(height: 20),
          StreamBuilder<List<Opportunity>>(
            stream: firestoreService.watchOpportunitiesForStartup(profile.uid),
            builder: (context, oppSnap) {
              final opportunities = oppSnap.data ?? const <Opportunity>[];
              return StreamBuilder<List<Application>>(
                stream:
                    firestoreService.watchApplicationsForStartup(profile.uid),
                builder: (context, appSnap) {
                  final applications = appSnap.data ?? const <Application>[];
                  final verifiedCount =
                      opportunities.where((o) => o.verified).length;
                  final pendingCount =
                      applications.where((a) => a.status == 'pending').length;


                  // Optional: show debugging if Firestore data isn't showing
                  // up correctly on the startup side.
                  // print('Startup ${profile.uid} opportunities count: ${opportunities.length}');


                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileStat(
                              value: '${opportunities.length}',
                              label: 'Posted',
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: ProfileStat(
                              value: '$verifiedCount',
                              label: 'Live',
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: ProfileStat(
                              value: '${applications.length}',
                              label: 'Applicants',
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: ProfileStat(
                              value: '$pendingCount',
                              label: 'Pending',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Recent applicants',
            actionLabel: 'View all',
            onActionTap: () => jumpToShellTab(context, AppRoutes.applications),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Application>>(
            stream: firestoreService.watchApplicationsForStartup(profile.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = (snapshot.data ?? const []).take(4).toList();
              if (items.isEmpty) {
                return const _EmptyHint(
                  text: 'No applicants yet. Post an opportunity to get started.',
                );
              }
              return Column(
                children: items
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ApplicationTile(
                          application: a,
                          primaryLabel: a.studentName ?? 'Student',
                          secondaryLabel: a.opportunityTitle ?? '',
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Your opportunities',
            actionLabel: 'Post new',
            onActionTap: () => jumpToShellTab(context, AppRoutes.discover),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Opportunity>>(
            stream: firestoreService.watchOpportunitiesForStartup(profile.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = snapshot.data ?? const [];
              if (items.isEmpty) {
                return const _EmptyHint(
                  text: "You haven't posted any opportunities yet.",
                );
              }
              return Column(
                children: items
                    .map(
                      (o) => OpportunityCard(
                        opportunity: o,
                        dense: true,
                        showVerifiedBadge: true,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pending.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pending.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.pending, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your opportunities will go live once our team verifies your account.',
              style: TextStyle(fontSize: 12.5, color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.lightGrey,
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.grey, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}
