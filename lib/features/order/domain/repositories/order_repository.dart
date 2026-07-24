import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';

abstract class OrderRepository {
  Future<Order> createOrder(Order order);
}
