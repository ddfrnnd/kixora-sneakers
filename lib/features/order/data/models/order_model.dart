import 'package:fashion_ecommerce/features/order/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.customerName,
    required super.customerPhone,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.items,
    super.status,
    super.totalPrice,
    super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString(),
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList()
          : [],
      status: json['status'] ?? 'Baru',
      totalPrice: json['total_price'] != null
          ? (json['total_price']).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'items': items
          .map((item) => {
                'product_id': item.productId,
                'product_name': item.productName ?? '',
                'quantity': item.quantity,
                'price': item.price,
                'image_url': item.imageUrl,
              })
          .toList(),
    };
  }
}

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.productId,
    super.productName,
    required super.quantity,
    required super.price,
    super.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'],
    );
  }
}
