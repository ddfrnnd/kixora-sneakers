import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/product/domain/repositories/product_repository.dart';

class GetProductDetail {
  final ProductRepository repository;

  GetProductDetail(this.repository);

  Future<Product> call(String id) async {
    return await repository.getProductById(id);
  }
}
