import 'category_model.dart';
import 'add_on_model.dart';
import 'size_model.dart';

class MenuItemModel {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final String? imagePath;
  final bool isAvailable;
  final bool isFeatured;
  final CategoryModel? category;
  final List<SizeModel> sizes;
  final List<AddOnModel> addOns;

  MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.imagePath,
    required this.isAvailable,
    required this.isFeatured,
    this.category,
    this.sizes = const [],
    this.addOns = const [],
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    // Parse nested sizes from pivot join
    final sizesList = (json['item_sizes'] as List?)
            ?.map((s) => SizeModel.fromJson(s['sizes'] as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse nested add-ons from pivot join
    final addOnsList = (json['item_add_ons'] as List?)
            ?.map((a) => AddOnModel.fromJson(a['add_ons'] as Map<String, dynamic>))
            .toList() ??
        [];

    return MenuItemModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imagePath: json['image_path'] as String?,
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      sizes: sizesList,
      addOns: addOnsList,
    );
  }
}