import 'package:fashion_ecommerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:fashion_ecommerce/features/order/data/models/order_model.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';
import 'package:fashion_ecommerce/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource remoteDatasource;

  OrderRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Order> createOrder(Order order) async {
    final orderModel = OrderModel(
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      address: order.address,
      latitude: order.latitude,
      longitude: order.longitude,
      items: order.items,
      totalPrice: order.totalPrice,
    );

    return await remoteDatasource.createOrder(orderModel);
  }
}
