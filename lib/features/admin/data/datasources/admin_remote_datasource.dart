import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/core/errors/exceptions.dart';
import 'package:fashion_ecommerce/features/admin/data/models/order_detail_model.dart';

class AdminRemoteDatasource {
  final FirebaseFirestore _firestore;

  AdminRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _ordersRef => _firestore.collection('orders');

  Future<List<OrderDetailModel>> getAllOrders() async {
    try {
      final snapshot =
          await _ordersRef.orderBy('created_at', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        // Convert Timestamp to ISO string
        if (data['created_at'] is Timestamp) {
          data['created_at'] =
              (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        return OrderDetailModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil data pesanan: $e');
    }
  }

  Future<OrderDetailModel> getOrderDetail(String id) async {
    try {
      final doc = await _ordersRef.doc(id).get();
      if (!doc.exists) {
        throw ServerException(message: 'Pesanan tidak ditemukan');
      }
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      if (data['created_at'] is Timestamp) {
        data['created_at'] =
            (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      return OrderDetailModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Gagal mengambil detail pesanan: $e');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _ordersRef.doc(id).update({'status': status});
    } catch (e) {
      throw ServerException(message: 'Gagal mengupdate status pesanan: $e');
    }
  }
}
