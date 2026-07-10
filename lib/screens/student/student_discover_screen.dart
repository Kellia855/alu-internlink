import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/search_field.dart';
import '../../widgets/status_filter_tabs.dart';
import '../opportunity_detail_screen.dart';

/// Searchable list of all opportunities students are allowed to see.
/// Both the query (`verified == true`) AND the Firestore security rules
/// enforce that students never receive unverified postings.
class StudentDiscoverScreen extends StatefulWidget {
  const StudentDiscoverScreen({super.key});

  @override
  State<StudentDiscoverScreen> createState() => _StudentDiscoverScreenState();
}

class _StudentDiscoverScreenState extends State<StudentDiscoverScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Opportunity> _applyFilters(List<Opportunity> items) {
    return items.where((o) {
      final matchesCategory = _category == 'All' || o.category == _category;
      if (!matchesCategory) return false;
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return o.title.toLowerCase().contains(q) ||
          o.companyName.toLowerCase().contains(q) ||
          o.skillsRequired.any((s) => s.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Discover')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchField(
              controller: _searchController,
              hint: 'Search by title, company, or skill...',
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 14),
            StatusFilterTabs(
              options: ['All', ...OpportunityCategory.all],
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Opportunity>>(
                stream: _firestoreService.watchVerifiedOpportunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Could not load opportunities.',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    );
                  }
                  final items = _applyFilters(snapshot.data ?? const []);
                  if (items.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          'No opportunities match your search.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 20, top: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final o = items[i];
                      return OpportunityCard(
                        opportunity: o,
                        isSaved: profile?.hasSaved(o.id) ?? false,
                        onToggleSave: profile == null
                            ? null
                            : () => _firestoreService.toggleSavedOpportunity(
                                  uid: profile.uid,
                                  opportunityId: o.id,
                                  currentlySaved: profile.hasSaved(o.id),
                                ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OpportunityDetailScreen(opportunity: o),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
