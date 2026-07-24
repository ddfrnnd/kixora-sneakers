import 'package:fashion_ecommerce/features/admin/domain/repositories/admin_repository.dart';

class UpdateOrderStatus {
  final AdminRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(String id, String status) async {
    return await repository.updateOrderStatus(id, status);
  }
}
