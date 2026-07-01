import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  bool isLoading = false;
  String? errorMessage;

  Stream<User?> get authStateChanges => _authRepository.authStateChanges();

  User? get currentUser => _authRepository.currentUser;

  Future<bool> isCurrentUserAdmin() => _authRepository.isCurrentUserAdmin();

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authRepository.login(email, password);

      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = false;
    errorMessage = null;
    notifyListeners();
    await _authRepository.logout();
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? 'Unable to sign in. Please check credentials.';
    }
    return 'Unable to sign in. Please try again.';
  }
}
