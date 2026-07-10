import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../models/application.dart';
import '../models/opportunity.dart';

/// All Firestore reads/writes for the `opportunities` and `applications`
/// collections live here so screens stay free of query logic.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunitiesRef =>
      _firestore.collection('opportunities');

  CollectionReference<Map<String, dynamic>> get _applicationsRef =>
      _firestore.collection('applications');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection('notifications');

  // ---------------------------------------------------------------------
  // Opportunities
  // ---------------------------------------------------------------------

  /// Students only ever see verified opportunities (enforced both here
  /// and in Firestore security rules).
  Stream<List<Opportunity>> watchVerifiedOpportunities() {
    return _opportunitiesRef
        .where('verified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Opportunity.fromDoc).toList());
  }

  /// A small "featured" slice for the student home screen.
  Stream<List<Opportunity>> watchFeaturedOpportunities({int limit = 5}) {
    return _opportunitiesRef
        .where('verified', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(Opportunity.fromDoc).toList());
  }

  /// All opportunities posted by a given startup, verified or not.
  Stream<List<Opportunity>> watchOpportunitiesForStartup(String startupId) {
    return _opportunitiesRef
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Opportunity.fromDoc).toList());
  }

  Future<void> postOpportunity(Opportunity opportunity) {
    return _opportunitiesRef.add(opportunity.toMap());
  }

  Future<Opportunity?> getOpportunity(String id) async {
    final doc = await _opportunitiesRef.doc(id).get();
    if (!doc.exists) return null;
    return Opportunity.fromDoc(doc);
  }

  // ---------------------------------------------------------------------
  // Applications
  // ---------------------------------------------------------------------

  /// Prevents a student from applying to the same opportunity twice.
  Future<bool> hasApplied({
    required String studentId,
    required String opportunityId,
  }) async {
    final snap = await _applicationsRef
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submitApplication(Application application) {
    return _applicationsRef.add(application.toMap());
  }

  /// All applications a student has submitted, most recent first.
  Stream<List<Application>> watchApplicationsForStudent(String studentId) {
    return _applicationsRef
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Application.fromDoc).toList());
  }

  /// All applicants across every opportunity a startup has posted.
  /// Relies on the denormalized `startupId` field on the application doc.
  Stream<List<Application>> watchApplicationsForStartup(String startupId) {
    return _applicationsRef
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Application.fromDoc).toList());
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) {
    return _applicationsRef.doc(applicationId).update({'status': status});
  }

  // ---------------------------------------------------------------------
  // Notifications (read-only from the client, see firestore.rules)
  // ---------------------------------------------------------------------

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromDoc).toList());
  }

  // ---------------------------------------------------------------------
  // Saved opportunities
  // Stored as a plain string-array field on the user's own document
  // (`users/{uid}.savedOpportunityIds`) rather than a new collection, so
  // toggling a bookmark is a single owner-scoped field update that's
  // already covered by the existing users/{uid} security rule.
  // ---------------------------------------------------------------------

  Future<void> toggleSavedOpportunity({
    required String uid,
    required String opportunityId,
    required bool currentlySaved,
  }) {
    return _usersRef.doc(uid).update({
      'savedOpportunityIds': currentlySaved
          ? FieldValue.arrayRemove([opportunityId])
          : FieldValue.arrayUnion([opportunityId]),
    });
  }

  /// One-time fetch of opportunities by id, used for the Saved
  /// Opportunities screen. Firestore's `whereIn` caps at 30 values, which
  /// comfortably covers a personal bookmark list; chunk defensively just
  /// in case a user saves a lot.
  Future<List<Opportunity>> fetchOpportunitiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final results = <Opportunity>[];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snap = await _opportunitiesRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snap.docs.map(Opportunity.fromDoc));
    }
    return results;
  }
}
