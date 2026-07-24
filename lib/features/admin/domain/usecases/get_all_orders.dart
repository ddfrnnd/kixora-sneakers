import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';
import 'package:fashion_ecommerce/features/admin/domain/repositories/admin_repository.dart';

class GetAllOrders {
  final AdminRepository repository;

  GetAllOrders(this.repository);

  Future<List<OrderDetail>> call() async {
    return await repository.getAllOrders();
  }
}
