import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(String id);
  Future<List<Product>> getProductsByCategory(String category);
  Future<List<Product>> searchProducts(String query);
}
