import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // "student" or "startup"
  final List<String> skills;
  final bool verified; // for startups
  final String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.skills,
    required this.verified,
    this.photoUrl,
  });

  factory UserProfile.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      skills: List<String>.from(data['skills'] ?? []),
      verified: data['verified'] ?? false,
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'skills': skills,
      'verified': verified,
      'photoUrl': photoUrl,
    };
  }
}
