import 'package:cloud_firestore/cloud_firestore.dart';

class Company {
  final String id;
  final String name;
  final String description;
  final bool verified;
  final String location;
  final String? logoUrl;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.verified,
    required this.location,
    this.logoUrl,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'verified': verified,
      'location': location,
      'logoUrl': logoUrl,
    };
  }
}
