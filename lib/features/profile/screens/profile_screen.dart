import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<UserProfile?> _fetchProfile(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserProfile.fromDoc(doc);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual logged-in user UID
    const uid = "demoStudent123";

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: FutureBuilder<UserProfile?>(
        future: _fetchProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Profile not found"));
          }
          final profile = snapshot.data!;
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
                      backgroundImage: profile.photoUrl != null
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: profile.photoUrl == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(profile.name,
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Role & Email
                Text("Role: ${profile.role}"),
                Text("Email: ${profile.email}"),
                const SizedBox(height: 20),

                // Skills
                Text("Skills", style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: profile.skills
                      .map((skill) => Chip(label: Text(skill)))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // Resume upload placeholder
                Text("Resume", style: Theme.of(context).textTheme.titleMedium),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Firebase Storage upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Resume upload coming soon")),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Resume"),
                ),
                const SizedBox(height: 20),

                // Application tracking shortcut
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/applications');
                  },
                  child: const Text("View My Applications"),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
