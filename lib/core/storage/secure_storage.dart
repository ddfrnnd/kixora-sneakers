import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fashion_ecommerce/core/constants/app_constants.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  // Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.keyAuthToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.keyAuthToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
  }

  // Admin email
  Future<void> saveAdminEmail(String email) async {
    await _storage.write(key: AppConstants.keyAdminEmail, value: email);
  }

  Future<String?> getAdminEmail() async {
    return await _storage.read(key: AppConstants.keyAdminEmail);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
