import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';

class OrderDetailModel extends OrderDetail {
  const OrderDetailModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.status,
    required super.totalPrice,
    required super.createdAt,
    required super.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? 'Baru',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderDetailItemModel.fromJson(item))
              .toList()
          : [],
    );
  }
}

class OrderDetailItemModel extends OrderDetailItem {
  const OrderDetailItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.price,
    super.imageUrl,
  });

  factory OrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}
