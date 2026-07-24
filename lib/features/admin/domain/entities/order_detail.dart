class OrderDetail {
  final String id;
  final String customerName;
  final String customerPhone;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final double totalPrice;
  final DateTime createdAt;
  final List<OrderDetailItem> items;

  const OrderDetail({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    required this.items,
  });
}

class OrderDetailItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderDetailItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  double get subtotal => price * quantity;
}
