import 'package:cloud_firestore/cloud_firestore.dart';

/// Status values used by the `applications` collection.
class ApplicationStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
}

/// Mirrors a document in the top-level `applications` Firestore collection.
///
/// Core required fields per spec: opportunityId, studentId, status, createdAt.
/// `startupId` is additionally denormalized onto the document at creation
/// time so Firestore security rules and startup-side queries don't need to
/// fan out and read every opportunity first. The remaining fields are
/// denormalized display-only copies for fast list rendering.
class Application {
  final String id;
  final String opportunityId;
  final String studentId;
  final String status;
  final DateTime? createdAt;

  final String startupId;
  final String? opportunityTitle;
  final String? companyName;
  final String? studentName;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.studentId,
    required this.status,
    required this.createdAt,
    required this.startupId,
    this.opportunityTitle,
    this.companyName,
    this.studentName,
  });

  factory Application.fromMap(String id, Map<String, dynamic> map) {
    return Application(
      id: id,
      opportunityId: (map['opportunityId'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      status: (map['status'] as String?) ?? ApplicationStatus.pending,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      startupId: (map['startupId'] as String?) ?? '',
      opportunityTitle: map['opportunityTitle'] as String?,
      companyName: map['companyName'] as String?,
      studentName: map['studentName'] as String?,
    );
  }

  factory Application.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Application.fromMap(doc.id, doc.data() ?? const {});
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'studentId': studentId,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'startupId': startupId,
      'opportunityTitle': opportunityTitle,
      'companyName': companyName,
      'studentName': studentName,
    };
  }
}
