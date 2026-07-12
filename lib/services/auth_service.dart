import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';

/// Thin wrapper around FirebaseAuth + the `users` collection.
/// Handles signup, login, logout, and creation of the user's
/// Firestore profile document.
class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Creates a Firebase Auth account, then writes the matching
  /// `users/{uid}` document with the fields required by the spec.
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // Keep the Auth display name in sync for convenience.
    await credential.user!.updateDisplayName(name);

    final data = <String, dynamic>{
      'name': name,
      'email': email.trim(),
      'role': role,
      'skills': <String>[],
      'verified': role == UserRole.startup ? false : true,
      'photoUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'savedOpportunityIds': <String>[],
    };

    await _usersRef.doc(uid).set(data);

    // Read back so createdAt reflects the resolved server timestamp
    // as closely as possible (falls back to "now" if not yet propagated).
    final snapshot = await _usersRef.doc(uid).get();
    return UserProfile.fromDoc(snapshot);
  }

  /// Signs a user in. The caller (UserProvider) is responsible for
  /// fetching the Firestore profile afterwards to determine role-based
  /// routing.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserProfile?> fetchUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromDoc(doc);
  }

  /// Partial update to the caller's own profile. Firestore rules block
  /// changing `role` or `verified` here regardless of what's passed.
  Future<void> updateProfile({
    required String uid,
    String? name,
    List<String>? skills,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (skills != null) data['skills'] = skills;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isEmpty) return;
    await _usersRef.doc(uid).update(data);
  }

  Future<void> uploadAndSetProfilePhoto({
    required String uid,
    required String photoDownloadUrl,
  }) async {
    // photoDownloadUrl comes from Firebase Storage; we only persist it.
    await updateProfile(
      uid: uid,
      photoUrl: photoDownloadUrl,
    );
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map(
          (doc) => doc.exists ? UserProfile.fromDoc(doc) : null,
        );
  }
}
