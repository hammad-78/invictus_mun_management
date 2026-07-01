import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  AuthRepository({
    AuthService? authService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? AuthService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _authService.authStateChanges();

  User? get currentUser => _authService.currentUser;

  Future<void> login(String email, String password) async {
    final credential = await _authService.login(email.trim(), password);
    final user = credential.user;

    if (user == null || !await isAdmin(user.uid)) {
      await _authService.logout();
      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'This account is not registered as an admin.',
      );
    }
  }

  Future<void> logout() => _authService.logout();

  Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    return isAdmin(user.uid);
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('admins').doc(uid).get();
    final data = doc.data();
    return doc.exists && data?['role'] == 'admin';
  }
}
