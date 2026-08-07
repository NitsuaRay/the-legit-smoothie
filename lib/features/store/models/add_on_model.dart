class AddOnModel {
  final int id;
  final String name;
  final double price;
  final bool isAvailable;

  AddOnModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    return AddOnModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'is_available': isAvailable,
      };
}