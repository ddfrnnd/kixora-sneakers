import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_ecommerce/core/errors/exceptions.dart';
import 'package:fashion_ecommerce/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Login (Admin & Customer)
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(message: 'Login gagal: user tidak ditemukan');
      }

      final token = await user.getIdToken();

      // Ambil data profil + role dari collection 'users' di Firestore
      String role = 'customer';
      String name = user.displayName ?? 'Pengguna';

      try {
        final doc = await _usersRef.doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          role = data['role'] ?? 'customer';
          name = data['name'] ?? name;
        } else if (email.contains('admin')) {
          // Fallback default admin
          role = 'admin';
          name = 'Admin Bakery';
          await _usersRef.doc(user.uid).set({
            'name': name,
            'email': email,
            'role': role,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {
        if (email.contains('admin')) role = 'admin';
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: name,
        role: role,
        token: token,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AuthException(message: 'Email belum terdaftar');
        case 'wrong-password':
          throw AuthException(message: 'Password salah');
        case 'invalid-email':
          throw AuthException(message: 'Format email tidak valid');
        case 'user-disabled':
          throw AuthException(message: 'Akun telah dinonaktifkan');
        case 'invalid-credential':
          throw AuthException(message: 'Email atau password salah');
        default:
          throw AuthException(message: 'Login gagal: ${e.message}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Login gagal: $e');
    }
  }

  /// Register Pelanggan Baru (Role: 'customer')
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(message: 'Registrasi gagal');
      }

      await user.updateDisplayName(name);

      // Simpan data pengguna baru dengan role 'customer' di Firestore
      await _usersRef.doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'customer',
        'created_at': FieldValue.serverTimestamp(),
      });

      final token = await user.getIdToken();

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: name,
        role: 'customer',
        token: token,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException(message: 'Email sudah terdaftar. Silakan login.');
        case 'weak-password':
          throw AuthException(message: 'Password terlalu lemah (minimal 6 karakter).');
        case 'invalid-email':
          throw AuthException(message: 'Format email tidak valid.');
        default:
          throw AuthException(message: 'Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'Registrasi gagal: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;
}
