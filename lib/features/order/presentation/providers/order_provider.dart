import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/core/network/network_info.dart';
import 'package:fashion_ecommerce/features/order/data/datasources/order_remote_datasource.dart';
import 'package:fashion_ecommerce/features/order/data/repositories/order_repository_impl.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart' as entity;

class OrderProvider extends ChangeNotifier {
  final NetworkInfo networkInfo;

  late final OrderRepositoryImpl _repository;

  bool _isLoading = false;
  String? _error;
  entity.Order? _lastOrder;

  // Form data
  String _customerName = '';
  String _customerPhone = '';
  String _address = '';

  OrderProvider({
    required this.networkInfo,
  }) {
    _repository = OrderRepositoryImpl(
      remoteDatasource: OrderRemoteDatasource(),
    );
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  entity.Order? get lastOrder => _lastOrder;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get address => _address;

  // Setters
  void setCustomerName(String value) => _customerName = value;
  void setCustomerPhone(String value) => _customerPhone = value;
  void setAddress(String value) => _address = value;

  /// Create a new order
  Future<bool> createOrder(entity.Order order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        _error = 'Tidak ada koneksi internet. Pastikan Anda terhubung.';
        return false;
      }

      _lastOrder = await _repository.createOrder(order);
      return true;
    } catch (e) {
      _error = 'Gagal membuat pesanan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset form
  void resetForm() {
    _customerName = '';
    _customerPhone = '';
    _address = '';
    _error = null;
    _lastOrder = null;
    notifyListeners();
  }
}
