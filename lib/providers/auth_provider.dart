import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';

class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'admin', 'analyst', 'user'
  final String? photoUrl;
  final bool isDemo;

  AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = 'analyst',
    this.photoUrl,
    this.isDemo = false,
  });

  factory AuthUser.fromFirebase(User user) {
    final email = user.email ?? 'analyst@cybershield.local';
    final name = (user.displayName != null && user.displayName!.isNotEmpty)
        ? user.displayName!
        : email.split('@').first.toUpperCase();

    return AuthUser(
      id: user.uid,
      email: email,
      displayName: name,
      role: email.contains('admin') ? 'admin' : 'analyst',
      photoUrl: user.photoURL,
      isDemo: false,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  AuthUser? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  AuthUser? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initFirebaseAuth();
  }

  Future<void> _initFirebaseAuth() async {
    await FirebaseAuthService.initialize();
    _authSubscription = FirebaseAuthService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        _user = AuthUser.fromFirebase(firebaseUser);
        _isAuthenticated = true;
      } else if (_user != null && !_user!.isDemo) {
        _user = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign In with Email & Password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _user = AuthUser.fromFirebase(credential.user!);
        _isAuthenticated = true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register Account with Email, Password & Display Name
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );
      if (credential.user != null) {
        _user = AuthUser.fromFirebase(credential.user!);
        _isAuthenticated = true;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign In with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuthService.signInWithGoogle();
      if (credential?.user != null) {
        _user = AuthUser.fromFirebase(credential!.user!);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false; // user cancelled
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send Password Reset Link
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuthService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Instant Demo Mode Access
  void loginAsDemo() {
    _user = AuthUser(
      id: 'usr-demo-${DateTime.now().millisecondsSinceEpoch}',
      email: 'analyst@cybershield.local',
      displayName: 'Lead Security Analyst',
      role: 'analyst',
      isDemo: true,
    );
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign Out
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseAuthService.signOut();
    } catch (_) {}
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    notifyListeners();
  }
}
