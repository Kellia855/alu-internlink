import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String opportunityId;
  final String studentId;
  final String status; // "applied", "reviewed", "accepted", "rejected"
  final DateTime createdAt;

  Application({
    required this.id,
    required this.opportunityId,
    required this.studentId,
    required this.status,
    required this.createdAt,
  });

  factory Application.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] ?? '',
      studentId: data['studentId'] ?? '',
      status: data['status'] ?? 'applied',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'studentId': studentId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
