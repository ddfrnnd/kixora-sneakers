import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Tambah item ke keranjang
  void addItem(Product product, [int quantity = 1]) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Update quantity item
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Hapus item dari keranjang
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Kosongkan keranjang
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Convert cart items to OrderItem list
  List<OrderItem> toOrderItems() {
    return _items
        .map((cartItem) => OrderItem(
              productId: cartItem.product.id,
              productName: cartItem.product.name,
              quantity: cartItem.quantity,
              price: cartItem.product.price,
              imageUrl: cartItem.product.imageUrl,
            ))
        .toList();
  }
}
