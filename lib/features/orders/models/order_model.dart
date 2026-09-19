class OrderItemModel {
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['product_name'] ?? json['products']?['name'] ?? 'Unknown Item',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

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
  final List<OrderItemModel> items; // <--- Added Order Items List

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
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      orderType: json['order_type'] ?? 'pickup',
      deliveryAddress: json['delivery_address'],
      contactNumber: json['contact_number'],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      // Parse order_items if included in Supabase join query
      items: json['order_items'] != null
          ? (json['order_items'] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList()
          : [],
    );
  }

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