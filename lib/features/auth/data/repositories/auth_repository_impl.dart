import 'package:fashion_ecommerce/core/storage/secure_storage.dart';
import 'package:fashion_ecommerce/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fashion_ecommerce/features/auth/domain/entities/user.dart';
import 'package:fashion_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.secureStorage,
  });

  @override
  Future<User> login(String email, String password) async {
    final user = await remoteDatasource.login(email, password);
    if (user.token != null) {
      await secureStorage.saveToken(user.token!);
      await secureStorage.saveAdminEmail(email);
    }
    return user;
  }

  @override
  Future<User> register(String name, String email, String password) async {
    final user = await remoteDatasource.register(name, email, password);
    if (user.token != null) {
      await secureStorage.saveToken(user.token!);
      await secureStorage.saveAdminEmail(email);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await remoteDatasource.logout();
    await secureStorage.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    return remoteDatasource.isLoggedIn;
  }
}
