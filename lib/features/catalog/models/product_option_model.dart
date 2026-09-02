class ProductOptionModel {
  final String id;
  final String productId;
  final String optionGroup; // 'Size', 'Sugar Level', 'Toppings', etc.
  final String optionName;  // '22oz', '50% Sugar', 'Extra Pearl'
  final double extraPrice;
  final bool isAvailable;

  ProductOptionModel({
    required this.id,
    required this.productId,
    required this.optionGroup,
    required this.optionName,
    required this.extraPrice,
    required this.isAvailable,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionModel(
      id: json['id'],
      productId: json['product_id'],
      optionGroup: json['option_group'],
      optionName: json['option_name'],
      extraPrice: (json['extra_price'] as num).toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }
}