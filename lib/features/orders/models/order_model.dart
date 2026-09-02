class OrderModel {
  final String id;
  final String userId;
  final String orderType; // 'delivery' or 'pickup'
  final String? deliveryAddress;
  final String? contactNumber;
  final double subtotal;
  final double deliveryFee;
  final double totalPrice;
  final String status; // 'pending', 'preparing', 'completed', 'cancelled'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderType,
    this.deliveryAddress,
    this.contactNumber,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'order_type': orderType,
      'delivery_address': deliveryAddress,
      'contact_number': contactNumber,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total_price': totalPrice,
      'status': status,
    };
  }
}