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

  MenuItemModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? price,
    String? imagePath,
    bool? isAvailable,
    bool? isFeatured,
    CategoryModel? category,
    List<SizeModel>? sizes,
    List<AddOnModel>? addOns,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      addOns: addOns ?? this.addOns,
    );
  }

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    // Parse nested sizes from pivot join
    final sizesList =
        (json['item_sizes'] as List?)
            ?.map((s) => SizeModel.fromJson(s['sizes'] as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse nested add-ons from pivot join
    final addOnsList =
        (json['item_add_ons'] as List?)
            ?.map(
              (a) => AddOnModel.fromJson(a['add_ons'] as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return MenuItemModel(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imagePath: json['image_path'] as String?,

      // Safely parse bool or 1/0 from DB, defaulting to true if null
      isAvailable:
          json['is_available'] == true ||
          json['is_available'] == 1 ||
          json['is_available'] == null,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,

      category: json['categories'] != null
          ? CategoryModel.fromJson(json['categories'] as Map<String, dynamic>)
          : null,
      sizes: sizesList,
      addOns: addOnsList,
    );
  }
}
