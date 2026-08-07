class SizeModel {
  final int id;
  final String name;
  final double priceModifier; // e.g., 0.0 for Regular, 20.0 for Large

  SizeModel({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      priceModifier: (json['price_modifier'] as num?)?.toDouble() ?? 0.0,
    );
  }
}