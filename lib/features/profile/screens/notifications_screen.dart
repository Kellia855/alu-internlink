import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Stream<QuerySnapshot> _notificationsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual logged-in user UID
    const uid = "demoStudent123";

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(data['message'] ?? ''),
                subtitle: Text(
                  (data['timestamp'] as Timestamp).toDate().toLocal().toString(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
