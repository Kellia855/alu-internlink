import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors a document in the top-level `notifications` collection.
/// Notifications are written by trusted backend logic (e.g. a Cloud
/// Function triggered on application-status changes or opportunity
/// verification) — clients only ever read them, which is why the
/// Firestore rules grant read-only access.
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      userId: (map['userId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      read: (map['read'] as bool?) ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AppNotification.fromMap(doc.id, doc.data() ?? const {});
  }
}
