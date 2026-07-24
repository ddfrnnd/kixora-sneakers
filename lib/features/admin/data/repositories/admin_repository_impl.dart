import 'package:fashion_ecommerce/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';
import 'package:fashion_ecommerce/features/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;

  AdminRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<OrderDetail>> getAllOrders() async {
    return await remoteDatasource.getAllOrders();
  }

  @override
  Future<OrderDetail> getOrderDetail(String id) async {
    return await remoteDatasource.getOrderDetail(id);
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    return await remoteDatasource.updateOrderStatus(id, status);
  }
}
