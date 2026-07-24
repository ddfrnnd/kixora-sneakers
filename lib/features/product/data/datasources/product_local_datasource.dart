import 'package:sqflite/sqflite.dart';
import 'package:fashion_ecommerce/core/database/database_helper.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';
import 'package:fashion_ecommerce/features/product/data/models/product_model.dart';

class ProductLocalDatasource {
  final DatabaseHelper _dbHelper;

  ProductLocalDatasource({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  /// Ambil semua produk dari cache SQLite
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final db = await _dbHelper.database;
      if (db == null) return [];
      final result = await db.query('products');
      return result.map((map) => ProductModel.fromMap(map)).toList();
    } catch (e) {
      AppLogger.warning('SQLite cache tidak dapat dibaca: $e');
      return [];
    }
  }

  /// Simpan produk ke cache SQLite
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final db = await _dbHelper.database;
      if (db == null) return;
      final batch = db.batch();

      batch.delete('products');

      for (final product in products) {
        batch.insert('products', product.toMap());
      }

      await batch.commit(noResult: true);
    } catch (e) {
      AppLogger.warning('Gagal menyimpan cache produk ke SQLite: $e');
    }
  }

  /// Simpan produk Kicks ke cache SQLite (tanpa menghapus produk yang sudah ada)
  Future<void> appendProducts(List<ProductModel> products) async {
    try {
      final db = await _dbHelper.database;
      if (db == null) return;
      final batch = db.batch();
      for (final product in products) {
        batch.insert('products', product.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
      AppLogger.success('✅ ${products.length} produk Kicks.dev ditambahkan ke cache SQLite');
    } catch (e) {
      AppLogger.warning('Gagal append produk Kicks ke SQLite: $e');
    }
  }

  /// Ambil produk berdasarkan ID dari cache
  Future<ProductModel?> getCachedProductById(String id) async {
    try {
      final db = await _dbHelper.database;
      if (db == null) return null;
      final result = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result.isNotEmpty) {
        return ProductModel.fromMap(result.first);
      }
      return null;
    } catch (e) {
      AppLogger.warning('Gagal membaca cache produk by ID: $e');
      return null;
    }
  }
}
