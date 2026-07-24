import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

Future<void> main() async {
  AppLogger.info('Menghapus semua produk dari Firestore...');
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('products').get();
  final batch = firestore.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
  AppLogger.success('Berhasil menghapus ${snapshot.docs.length} produk dari Firestore');
}
