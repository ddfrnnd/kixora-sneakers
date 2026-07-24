import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/core/storage/secure_storage.dart';
import 'package:fashion_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fashion_ecommerce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fashion_ecommerce/features/auth/domain/entities/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorage secureStorage;

  late final AuthRemoteDatasource _remoteDatasource;
  late final AuthRepositoryImpl _repository;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AuthProvider({
    required this.secureStorage,
  }) {
    _remoteDatasource = AuthRemoteDatasource();
    _repository = AuthRepositoryImpl(
      remoteDatasource: _remoteDatasource,
      secureStorage: secureStorage,
    );
    _checkCurrentUser();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> _checkCurrentUser() async {
    final firebaseUser = _remoteDatasource.currentUser;
    if (firebaseUser != null) {
      // Ambil admin email tersimpan
      final savedEmail = await secureStorage.getAdminEmail();
      final isSavedAdmin = (savedEmail ?? '').contains('admin');

      _user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Pengguna',
        role: isSavedAdmin ? 'admin' : 'customer',
      );
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  /// Check login status
  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _repository.isLoggedIn();
    await _checkCurrentUser();
    notifyListeners();
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.login(email, password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('AuthException: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register user
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _repository.register(name, email, password);
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('AuthException: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update Profile Name
  Future<bool> updateProfileName(String newName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fbUser = _remoteDatasource.currentUser;
      if (fbUser != null) {
        await fbUser.updateDisplayName(newName);
        await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).update({
          'name': newName,
        });

        // Update user di memori
        if (_user != null) {
          _user = User(
            id: _user!.id,
            email: _user!.email,
            name: newName,
            role: _user!.role,
            token: _user!.token,
          );
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }
}
