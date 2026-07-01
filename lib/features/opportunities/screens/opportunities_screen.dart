import 'package:flutter/material.dart';
import '../../../models/opportunity.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/tag_chip.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';

class OpportunitiesScreen extends StatelessWidget {
  final List<Opportunity> opportunities;

  const OpportunitiesScreen({super.key, this.opportunities = const []});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 1,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Opportunities', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    TagChip('All'),
                    SizedBox(width: 8),
                    TagChip('Engineering'),
                    SizedBox(width: 8),
                    TagChip('Design'),
                    SizedBox(width: 8),
                    TagChip('Marketing'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: opportunities.isEmpty
                    ? const Center(child: Text('No opportunities yet'))
                    : ListView.builder(
                        itemCount: opportunities.length,
                        itemBuilder: (context, i) {
                          final opp = opportunities[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.business)),
                              title: Text(opp.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${opp.location} • ${opp.duration}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opp)),
                                  );
                                },
                                child: const Text('View'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
