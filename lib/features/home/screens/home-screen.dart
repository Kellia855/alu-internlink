import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/opportunity.dart';
import '../../opportunities/screens/opportunity_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<List<Opportunity>> _opportunitiesStream() {
    return FirebaseFirestore.instance
        .collection('opportunities')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Opportunity.fromDoc(doc)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ALU InternLink")),
      body: Column(
        children: [
          // Filters row
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                FilterChip(label: Text("All Feed"), selected: true, onSelected: null),
                SizedBox(width: 8),
                FilterChip(label: Text("Software"), selected: false, onSelected: null),
                SizedBox(width: 8),
                FilterChip(label: Text("Design"), selected: false, onSelected: null),
                SizedBox(width: 8),
                FilterChip(label: Text("Marketing"), selected: false, onSelected: null),
              ],
            ),
          ),
          const Divider(),
          // Opportunity list
          Expanded(
            child: StreamBuilder<List<Opportunity>>(
              stream: _opportunitiesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading opportunities"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final opportunities = snapshot.data!;
                if (opportunities.isEmpty) {
                  return const Center(child: Text("No opportunities available"));
                }
                return ListView.builder(
                  itemCount: opportunities.length,
                  itemBuilder: (context, index) {
                    final opp = opportunities[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(opp.title),
                        subtitle: Text("${opp.description}\n${opp.location} • ${opp.duration}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OpportunityDetailScreen(opportunity: opp),
                              ),
                            );
                          },
                          child: const Text("Quick Apply"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/applications');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Applications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
