class FlavorModel {
  final int id;
  final String name;
  final bool isAvailable;

  FlavorModel({
    required this.id,
    required this.name,
    required this.isAvailable,
  });

  factory FlavorModel.fromJson(Map<String, dynamic> json) {
    return FlavorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_available': isAvailable,
    };
  }
}