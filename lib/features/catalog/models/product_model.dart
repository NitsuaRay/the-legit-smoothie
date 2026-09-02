class ProductModel {
  final String id;
  final String? categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final String? imageUrl;
  final bool isAvailable;

  ProductModel({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    this.imageUrl,
    required this.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['base_price'] as num).toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}