import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/opportunity_card.dart';
import '../opportunity_detail_screen.dart';

class SavedOpportunitiesScreen extends StatelessWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProvider>().profile;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Opportunity>>(
              future: firestoreService
                  .fetchOpportunitiesByIds(profile.savedOpportunityIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load saved opportunities.',
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
                          Icon(Icons.bookmark_border_rounded,
                              size: 40, color: AppColors.lightGrey),
                          SizedBox(height: 12),
                          Text(
                            'Bookmark opportunities you like and they\'ll show up here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final o = items[i];
                    return OpportunityCard(
                      opportunity: o,
                      dense: true,
                      isSaved: true,
                      onToggleSave: () => firestoreService.toggleSavedOpportunity(
                        uid: profile.uid,
                        opportunityId: o.id,
                        currentlySaved: true,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OpportunityDetailScreen(opportunity: o),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
