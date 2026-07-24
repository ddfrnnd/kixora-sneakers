import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/core/errors/exceptions.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';
import 'package:fashion_ecommerce/features/product/data/models/product_model.dart';

class ProductRemoteDatasource {
  final FirebaseFirestore _firestore;

  ProductRemoteDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _productsRef => _firestore.collection('products');

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _productsRef.get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        
        // Convert Timestamp to ISO String if present
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }

        return ProductModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Gagal mengambil data produk: $e');
    }
  }

  /// Simpan produk (dari Kicks.dev) ke Firestore
  Future<void> saveProducts(List<ProductModel> products) async {
    try {
      final batch = _firestore.batch();
      for (final product in products) {
        final docRef = _productsRef.doc(product.id);
        batch.set(docRef, {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'category': product.category,
          'image_url': product.imageUrl,
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      AppLogger.success('✅ ${products.length} produk Kicks.dev disimpan ke Firestore');
    } catch (e) {
      AppLogger.warning('Gagal simpan produk ke Firestore: $e');
    }
  }

  Future<ProductModel> getProductById(String id) async {
    try {
      final doc = await _productsRef.doc(id).get();
      if (!doc.exists) {
        throw ServerException(message: 'Produk tidak ditemukan');
      }
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;

      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      return ProductModel.fromJson(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Gagal mengambil detail produk: $e');
    }
  }
}
