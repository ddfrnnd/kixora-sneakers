import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';

abstract class AdminRepository {
  Future<List<OrderDetail>> getAllOrders();
  Future<OrderDetail> getOrderDetail(String id);
  Future<void> updateOrderStatus(String id, String status);
}
