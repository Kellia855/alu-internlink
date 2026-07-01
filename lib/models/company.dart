import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMember {
  final String name;
  final String role;
  final String avatarUrl;

  const TeamMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}

class Company {
  final String id;
  final String name;
  final String description;
  final bool verified;
  final String location;
  final String? logoUrl;
  final String tagline;
  final List<String> tags;
  final List<TeamMember> teamMembers;
  final int projectsShipped;
  final int openInternships;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.verified,
    required this.location,
    this.logoUrl,
    this.tagline = '',
    this.tags = const [],
    this.teamMembers = const [],
    this.projectsShipped = 0,
    this.openInternships = 0,
  });

  factory Company.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Company(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      verified: data['verified'] ?? false,
      location: data['location'] ?? '',
      logoUrl: data['logoUrl'],
      tagline: data['tagline'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      projectsShipped: data['projectsShipped'] ?? 0,
      openInternships: data['openInternships'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'verified': verified,
      'location': location,
      'logoUrl': logoUrl,
      'tagline': tagline,
      'tags': tags,
      'projectsShipped': projectsShipped,
      'openInternships': openInternships,
    };
  }
}
