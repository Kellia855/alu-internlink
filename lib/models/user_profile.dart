import 'package:cloud_firestore/cloud_firestore.dart';

/// The two supported account roles in InternLink.
class UserRole {
  static const String student = 'student';
  static const String startup = 'startup';
}

/// Mirrors a document in the top-level `users/{uid}` Firestore collection.
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // UserRole.student or UserRole.startup
  final List<String> skills;
  final bool verified;
  final String? photoUrl;
  final DateTime? createdAt;

  /// IDs of opportunities the user has bookmarked. Not part of the
  /// original required schema, but stored as a plain array field on the
  /// same user document (rather than a new collection) so "save" stays a
  /// single, rule-simple field update.
  final List<String> savedOpportunityIds;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.skills,
    required this.verified,
    required this.photoUrl,
    required this.createdAt,
    this.savedOpportunityIds = const [],
  });

  bool get isStudent => role == UserRole.student;
  bool get isStartup => role == UserRole.startup;

  /// For startup accounts, `name` doubles as the company name so the
  /// signup flow doesn't need a separate field.
  String get companyName => name;

  bool hasSaved(String opportunityId) =>
      savedOpportunityIds.contains(opportunityId);

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: (map['role'] as String?) ?? UserRole.student,
      skills: List<String>.from(map['skills'] as List? ?? const []),
      verified: (map['verified'] as bool?) ?? false,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      savedOpportunityIds:
          List<String>.from(map['savedOpportunityIds'] as List? ?? const []),
    );
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserProfile.fromMap(doc.id, doc.data() ?? const {});
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'skills': skills,
      'verified': verified,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'savedOpportunityIds': savedOpportunityIds,
    };
  }

  UserProfile copyWith({
    String? name,
    List<String>? skills,
    String? photoUrl,
    List<String>? savedOpportunityIds,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      skills: skills ?? this.skills,
      verified: verified,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      savedOpportunityIds: savedOpportunityIds ?? this.savedOpportunityIds,
    );
  }
}
