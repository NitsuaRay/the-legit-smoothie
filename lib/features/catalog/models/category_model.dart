class CategoryModel {
  final String id;
  final String name;
  final int displayOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      displayOrder: json['display_order'] ?? 0,
    );
  }
}