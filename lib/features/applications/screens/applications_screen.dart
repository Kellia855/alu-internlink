import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/application.dart';
import '../../../models/opportunity.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  Stream<List<Application>> _applicationsStream(String studentId) {
    return FirebaseFirestore.instance
        .collection('applications')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Application.fromDoc(doc)).toList());
  }

  Future<Opportunity?> _fetchOpportunity(String opportunityId) async {
    final doc = await FirebaseFirestore.instance
        .collection('opportunities')
        .doc(opportunityId)
        .get();
    if (doc.exists) {
      return Opportunity.fromDoc(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual logged-in student UID
    const studentId = "demoStudent123";

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: StreamBuilder<List<Application>>(
        stream: _applicationsStream(studentId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading applications"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final applications = snapshot.data!;
          if (applications.isEmpty) {
            return const Center(child: Text("No applications yet"));
          }
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              return FutureBuilder<Opportunity?>(
                future: _fetchOpportunity(app.opportunityId),
                builder: (context, oppSnapshot) {
                  if (!oppSnapshot.hasData) {
                    return const ListTile(title: Text("Loading opportunity..."));
                  }
                  final opp = oppSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(opp.title),
                      subtitle: Text("Status: ${app.status}"),
                      trailing: Icon(
                        app.status == "accepted"
                            ? Icons.check_circle
                            : app.status == "rejected"
                                ? Icons.cancel
                                : Icons.hourglass_top,
                        color: app.status == "accepted"
                            ? Colors.green
                            : app.status == "rejected"
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
