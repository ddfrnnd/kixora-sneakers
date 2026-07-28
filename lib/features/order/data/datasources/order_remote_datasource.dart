import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fashion_ecommerce/core/errors/exceptions.dart';
import 'package:fashion_ecommerce/features/order/data/models/order_model.dart';

class OrderRemoteDatasource {
  final FirebaseFirestore _firestore;

  OrderRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ordersRef => _firestore.collection('orders');

  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final data = order.toJson();
      data['status'] = 'Baru';
      data['created_at'] = FieldValue.serverTimestamp();
      data['total_price'] = order.totalPrice ?? 0;

      // Automatically attach logged in user details for user-scoped filtering
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        data['user_email'] = currentUser.email;
        data['user_id'] = currentUser.uid;
      }

      // Tambahkan info produk ke items
      final items = order.items.map((item) => {
        'product_id': item.productId,
        'product_name': item.productName ?? '',
        'quantity': item.quantity,
        'price': item.price,
        'image_url': item.imageUrl,
      }).toList();
      data['items'] = items;

      final docRef = await _ordersRef.add(data);

      return OrderModel(
        id: docRef.id,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        address: order.address,
        latitude: order.latitude,
        longitude: order.longitude,
        items: order.items,
        status: 'Baru',
        totalPrice: order.totalPrice,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw ServerException(message: 'Gagal membuat pesanan: $e');
    }
  }
}
