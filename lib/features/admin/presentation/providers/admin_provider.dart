import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:fashion_ecommerce/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';

class AdminProvider extends ChangeNotifier {
  late final AdminRepositoryImpl _repository;

  List<OrderDetail> _orders = [];
  OrderDetail? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  AdminProvider() {
    _repository = AdminRepositoryImpl(
      remoteDatasource: AdminRemoteDatasource(),
    );
  }

  // Getters
  List<OrderDetail> get orders => _orders;
  OrderDetail? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all orders
  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getAllOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch order detail
  Future<void> fetchOrderDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.getOrderDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      await _repository.updateOrderStatus(id, status);
      // Update locally
      final index = _orders.indexWhere((o) => o.id == id);
      if (index >= 0) {
        await fetchOrders();
      }
      if (_selectedOrder?.id == id) {
        await fetchOrderDetail(id);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
