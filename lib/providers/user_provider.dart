import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, signedOut, signedIn }

/// Single source of truth for "who is logged in and what is their role".

class UserProvider extends ChangeNotifier {
  UserProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<UserProfile?>? _profileSub;

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _profile;
  String? _errorMessage;
  bool _busy = false;

  AuthStatus get status => _status;
  UserProfile? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _busy;
  AuthService get authService => _authService;

  bool get isLoggedIn => _status == AuthStatus.signedIn && _profile != null;

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();

    if (user == null) {
      _status = AuthStatus.signedOut;
      _profile = null;
      notifyListeners();
      return;
    }

    _profileSub = _authService.watchUserProfile(user.uid).listen((profile) {
      _profile = profile;
      _status = profile != null ? AuthStatus.signedIn : AuthStatus.signedOut;
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) => _runGuarded(() async {
        await _authService.signUp(
          name: name,
          email: email,
          password: password,
          role: role,
        );
      });

  Future<bool> signIn({
    required String email,
    required String password,
  }) => _runGuarded(() async {
        await _authService.signIn(email: email, password: password);
      });

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> _runGuarded(Future<void> Function() action) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _busy = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _busy = false;
      _errorMessage = _mapAuthError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _busy = false;
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Please choose a stronger password (6+ characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
