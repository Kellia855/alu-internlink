import 'package:cloud_firestore/cloud_firestore.dart';

/// Fixed set of categories used for the "Browse by category" grid.
class OpportunityCategory {
  OpportunityCategory._();
  static const String design = 'Design';
  static const String engineering = 'Engineering';
  static const String marketing = 'Marketing';
  static const String data = 'Data';
  static const String other = 'Other';

  static const List<String> all = [design, engineering, marketing, data, other];
}

/// Mirrors a document in the top-level `opportunities` Firestore collection.
class Opportunity {
  final String id;
  final String title;
  final String companyName;
  final String startupId;
  final bool verified;
  final DateTime? createdAt;
  final String? imageUrl;
  final String description;

  // Optional extra fields kept flexible for a richer listing UI.
  // Firestore is schema-less, so these are safe to omit on write.
  final String? location;
  final List<String> skillsRequired;
  final String category; // Design, Engineering, Marketing, Data, Other
  final String commitment; // e.g. "Part-time (8-10 hrs/week)"

  const Opportunity({
    required this.id,
    required this.title,
    required this.companyName,
    required this.startupId,
    required this.verified,
    required this.createdAt,
    required this.imageUrl,
    required this.description,
    this.location,
    this.skillsRequired = const [],
    this.category = OpportunityCategory.other,
    this.commitment = '',
  });

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) {
    return Opportunity(
      id: id,
      title: (map['title'] as String?) ?? '',
      companyName: (map['companyName'] as String?) ?? '',
      startupId: (map['startupId'] as String?) ?? '',
      verified: (map['verified'] as bool?) ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      imageUrl: map['imageUrl'] as String?,
      description: (map['description'] as String?) ?? '',
      location: map['location'] as String?,
      skillsRequired:
          List<String>.from(map['skillsRequired'] as List? ?? const []),
      category: (map['category'] as String?) ?? OpportunityCategory.other,
      commitment: (map['commitment'] as String?) ?? '',
    );
  }

  factory Opportunity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Opportunity.fromMap(doc.id, doc.data() ?? const {});
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'companyName': companyName,
      'startupId': startupId,
      'verified': verified,
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'description': description,
      'location': location,
      'skillsRequired': skillsRequired,
      'category': category,
      'commitment': commitment,
    };
  }
}
