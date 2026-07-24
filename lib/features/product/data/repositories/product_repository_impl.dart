import 'package:fashion_ecommerce/core/network/network_info.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';
import 'package:fashion_ecommerce/features/product/data/datasources/product_local_datasource.dart';
import 'package:fashion_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final products = await remoteDatasource.getAllProducts();
      // Cache ke SQLite secara async tanpa memblokir UI
      localDatasource.cacheProducts(products).catchError((e) {
        AppLogger.warning('Cache skip: $e');
      });
      return products;
    } catch (e) {
      AppLogger.warning('Gagal mengambil dari remote, mencoba cache lokal: $e');
      final cached = await localDatasource.getCachedProducts();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      return await remoteDatasource.getProductById(id);
    } catch (e) {
      final cached = await localDatasource.getCachedProductById(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    final allProducts = await getAllProducts();
    return allProducts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await getAllProducts();
    return allProducts
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
