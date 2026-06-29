import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/company.dart';
import '../../../models/opportunity.dart';

class CompanyProfileScreen extends StatelessWidget {
  final String companyId;

  const CompanyProfileScreen({super.key, required this.companyId});

  Future<Company?> _fetchCompany() async {
    final doc = await FirebaseFirestore.instance.collection('companies').doc(companyId).get();
    if (doc.exists) {
      return Company.fromDoc(doc);
    }
    return null;
  }

  Stream<List<Opportunity>> _companyOpportunitiesStream() {
    return FirebaseFirestore.instance
        .collection('opportunities')
        .where('startupId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Opportunity.fromDoc(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Profile")),
      body: FutureBuilder<Company?>(
        future: _fetchCompany(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Company not found"));
          }
          final company = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: company.logoUrl != null
                          ? NetworkImage(company.logoUrl!)
                          : null,
                      child: company.logoUrl == null
                          ? const Icon(Icons.business, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(company.name,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    if (company.verified)
                      const Icon(Icons.verified, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 10),
                Text(company.description),
                const SizedBox(height: 20),

                // Location
                Text("Location: ${company.location}"),
                const SizedBox(height: 20),

                // Active Opportunities
                Text("Active Opportunities",
                    style: Theme.of(context).textTheme.titleMedium),
                StreamBuilder<List<Opportunity>>(
                  stream: _companyOpportunitiesStream(),
                  builder: (context, oppSnapshot) {
                    if (oppSnapshot.hasError) {
                      return const Text("Error loading opportunities");
                    }
                    if (!oppSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final opportunities = oppSnapshot.data!;
                    if (opportunities.isEmpty) {
                      return const Text("No active opportunities");
                    }
                    return Column(
                      children: opportunities.map((opp) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(opp.title),
                            subtitle: Text("${opp.location} • ${opp.duration}"),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/opportunityDetail',
                                  arguments: opp,
                                );
                              },
                              child: const Text("View"),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
