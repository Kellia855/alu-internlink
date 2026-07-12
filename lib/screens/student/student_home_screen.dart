import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_header_bar.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/recommended_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_header.dart';
import '../main_shell.dart';
import '../opportunity_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Opportunity opportunity) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final firstName = (profile?.name.isNotEmpty ?? false)
        ? profile!.name.split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.maroon,
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            AppHeaderBar(
              greeting: 'Hello, $firstName!',
              subtitle: 'Find meaningful ways to grow your portifolio.',
              photoUrl: profile?.photoUrl,
              initials: firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
            ),
            const SizedBox(height: 20),
            SearchField(
              controller: _searchController,
              hint: 'Search opportunities...',
              onFilterTap: () => jumpToShellTab(context, AppRoutes.discover),
              onChanged: (_) => jumpToShellTab(context, AppRoutes.discover),
            ),
            const SizedBox(height: 24),
            CategoryGrid(
              onCategoryTap: (_) => jumpToShellTab(context, AppRoutes.discover),
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Recommended',
              actionLabel: 'See all',
              onActionTap: () => jumpToShellTab(context, AppRoutes.discover),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 172,
              child: StreamBuilder<List<Opportunity>>(
                stream: _firestoreService.watchFeaturedOpportunities(limit: 6),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? const [];
                  if (items.isEmpty) {
                    return const _EmptyHint(
                      text: 'No recommended opportunities yet.',
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => RecommendedCard(
                      opportunity: items[i],
                      onTap: () => _openDetail(items[i]),
                      isSaved: profile?.hasSaved(items[i].id) ?? false,
                      onToggleSave: profile == null
                          ? null
                          : () => _firestoreService.toggleSavedOpportunity(
                                uid: profile.uid,
                                opportunityId: items[i].id,
                                currentlySaved: profile.hasSaved(items[i].id),
                              ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(
              title: 'Recent opportunities',
              actionLabel: 'See all',
              onActionTap: () => jumpToShellTab(context, AppRoutes.discover),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Opportunity>>(
              stream: _firestoreService.watchVerifiedOpportunities(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = (snapshot.data ?? const []).take(6).toList();
                if (items.isEmpty) {
                  return const _EmptyHint(
                    text: 'No opportunities posted yet. Check back soon!',
                  );
                }
                return Column(
                  children: items
                      .map(
                        (o) => OpportunityCard(
                          opportunity: o,
                          dense: true,
                          onTap: () => _openDetail(o),
                          isSaved: profile?.hasSaved(o.id) ?? false,
                          onToggleSave: profile == null
                              ? null
                              : () => _firestoreService.toggleSavedOpportunity(
                                    uid: profile.uid,
                                    opportunityId: o.id,
                                    currentlySaved: profile.hasSaved(o.id),
                                  ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
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
