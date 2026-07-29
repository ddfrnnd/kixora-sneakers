import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'rating': product.rating,
      'soldCount': product.soldCount,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'Produk Sepatu',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] as String? ?? 'Sneakers',
        imageUrl: json['imageUrl'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        soldCount: (json['soldCount'] as num?)?.toInt() ?? 0,
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  String? _currentUserId;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.fold(0, (acc, item) => acc + item.quantity);
  double get totalPrice =>
      _items.fold(0.0, (acc, item) => acc + item.subtotal);

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Dipanggil otomatis ketika status Auth berubah (User login / logout / ganti akun)
  Future<void> updateUser(String? newUserId) async {
    if (_currentUserId == newUserId) return;

    // Simpan keranjang akun sebelumnya
    await _saveCart();

    _currentUserId = newUserId;
    _items.clear();

    if (newUserId != null && newUserId.isNotEmpty) {
      // 1. Coba muat cepat dari penyimpanan lokal HP
      await _loadFromPrefs();
      notifyListeners();

      // 2. Sinkronkan dengan Firestore Database real-time per User ID
      await _loadFromFirestore();
    } else {
      notifyListeners();
    }
  }

  /// Muat dari SharedPreferences lokal
  Future<void> _loadFromPrefs() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cart_items_$_currentUserId');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _items.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _items.add(CartItem.fromJson(item));
          }
        }
      }
    } catch (_) {}
  }

  /// Muat dari Firestore Database
  Future<void> _loadFromFirestore() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('carts')
          .doc(_currentUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawItems = data['items'] as List<dynamic>?;
        if (rawItems != null) {
          _items.clear();
          for (final item in rawItems) {
            if (item is Map<String, dynamic>) {
              _items.add(CartItem.fromJson(item));
            }
          }
          await _saveToPrefs();
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  /// Simpan ke SharedPreferences & Firestore Database
  Future<void> _saveCart() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    // 1. Simpan Lokal HP
    await _saveToPrefs();

    // 2. Simpan Database Firestore
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(_currentUserId)
          .set({
        'userId': _currentUserId,
        'items': _items.map((i) => i.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_items.map((i) => i.toJson()).toList());
      await prefs.setString('cart_items_$_currentUserId', jsonString);
    } catch (_) {}
  }

  /// Tambah item ke keranjang
  void addItem(Product product, [int quantity = 1]) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    _saveCart();
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
      _saveCart();
      notifyListeners();
    }
  }

  /// Hapus item dari keranjang
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  /// Kosongkan keranjang
  void clearCart() {
    _items.clear();
    _saveCart();
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
