import 'package:cloud_firestore/cloud_firestore.dart';
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
      final doc = await docRef.get();
      final responseData = doc.data() as Map<String, dynamic>;
      responseData['id'] = doc.id;

      // Convert Timestamp to string for parsing
      if (responseData['created_at'] is Timestamp) {
        responseData['created_at'] =
            (responseData['created_at'] as Timestamp).toDate().toIso8601String();
      }

      return OrderModel.fromJson(responseData);
    } catch (e) {
      throw ServerException(message: 'Gagal membuat pesanan: $e');
    }
  }
}
