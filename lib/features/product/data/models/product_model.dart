import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    super.imageUrl,
    super.createdAt,
    super.updatedAt,
  });

  static String _cleanName(String rawName) {
    return rawName.replaceAll(RegExp(r'\s*\[Kicks?\.dev\]', caseSensitive: false), '').trim();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = (json['price'] ?? 0).toDouble();
    if (parsedPrice > 0 && parsedPrice < 1000) {
      parsedPrice = parsedPrice * 16200;
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: _cleanName(json['name'] ?? ''),
      description: json['description'] ?? '',
      price: parsedPrice,
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    double parsedPrice = (map['price'] ?? 0).toDouble();
    if (parsedPrice > 0 && parsedPrice < 1000) {
      parsedPrice = parsedPrice * 16200;
    }

    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: _cleanName(map['name'] ?? ''),
      description: map['description'] ?? '',
      price: parsedPrice,
      category: map['category'] ?? '',
      imageUrl: map['image_url'],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
