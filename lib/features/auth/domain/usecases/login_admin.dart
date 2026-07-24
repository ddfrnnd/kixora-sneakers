import 'package:fashion_ecommerce/features/auth/domain/entities/user.dart';
import 'package:fashion_ecommerce/features/auth/domain/repositories/auth_repository.dart';

class LoginAdmin {
  final AuthRepository repository;

  LoginAdmin(this.repository);

  Future<User> call(String email, String password) async {
    return await repository.login(email, password);
  }
}
