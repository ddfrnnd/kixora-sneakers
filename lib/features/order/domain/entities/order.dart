class Order {
  final String? id;
  final String customerName;
  final String customerPhone;
  final String address;
  final double latitude;
  final double longitude;
  final List<OrderItem> items;
  final String status;
  final double? totalPrice;
  final DateTime? createdAt;

  const Order({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.items,
    this.status = 'Baru',
    this.totalPrice,
    this.createdAt,
  });
}

class OrderItem {
  final String productId;
  final String? productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderItem({
    required this.productId,
    this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
}
