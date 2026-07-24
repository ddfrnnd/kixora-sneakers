import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/product/domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getAllProducts();
  }
}
