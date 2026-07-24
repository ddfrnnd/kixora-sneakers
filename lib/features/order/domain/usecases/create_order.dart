import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';
import 'package:fashion_ecommerce/features/order/domain/repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<Order> call(Order order) async {
    return await repository.createOrder(order);
  }
}
