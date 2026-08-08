import 'menu_item_model.dart';

class FeaturedItemModel {
  final int id;
  final int menuItemId;
  final int slotNumber; // 1: Hero, 2: Grid, 3: Carousel
  final int displayOrder;
  final String? customBadge;
  final bool isActive;
  final MenuItemModel? menuItem;

  FeaturedItemModel({
    required this.id,
    required this.menuItemId,
    required this.slotNumber,
    required this.displayOrder,
    this.customBadge,
    required this.isActive,
    this.menuItem,
  });

  FeaturedItemModel copyWith({
    int? id,
    int? menuItemId,
    int? slotNumber,
    int? displayOrder,
    String? customBadge,
    bool? isActive,
    MenuItemModel? menuItem,
  }) {
    return FeaturedItemModel(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      slotNumber: slotNumber ?? this.slotNumber,
      displayOrder: displayOrder ?? this.displayOrder,
      customBadge: customBadge ?? this.customBadge,
      isActive: isActive ?? this.isActive,
      menuItem: menuItem ?? this.menuItem,
    );
  }

  factory FeaturedItemModel.fromJson(Map<String, dynamic> json) {
    return FeaturedItemModel(
      id: json['id'] as int,
      menuItemId: json['menu_item_id'] as int,
      slotNumber: json['slot_number'] as int,
      displayOrder: (json['display_order'] as int?) ?? 1,
      customBadge: json['custom_badge'] as String?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      menuItem: json['menu_items'] != null
          ? MenuItemModel.fromJson(json['menu_items'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item_id': menuItemId,
      'slot_number': slotNumber,
      'display_order': displayOrder,
      'custom_badge': customBadge,
      'is_active': isActive,
    };
  }
}