import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

/// Seed data produk sepatu ke Cloud Firestore
class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedIfEmpty() async {
    final snapshot = await _firestore.collection('products').get();
    
    if (snapshot.docs.isNotEmpty) {
      bool hasProductsWithoutImages = snapshot.docs.any((doc) {
        final imgUrl = doc.data()['image_url'] ?? '';
        return imgUrl.toString().isEmpty;
      });
      if (hasProductsWithoutImages) {
        AppLogger.info('Membersihkan produk lama tanpa gambar dari Firestore, akan re-fetch dari Kicks.dev...');
        await _clearProducts();
      }
    }
  }

  static Future<void> _clearProducts() async {
    final snapshot = await _firestore.collection('products').get();
    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

}
