import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/add_on_model.dart';
import '../models/size_model.dart';
import '../models/menu_item_model.dart';

class MenuDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ==========================================
  // FETCH METHODS
  // ==========================================

  /// Fetch all active categories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabase
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }

  /// Fetch all menu items along with their joined categories, sizes, and add-ons
  Future<List<MenuItemModel>> getMenuItems() async {
    final response = await _supabase
        .from('menu_items')
        .select('''
          *,
          categories (*),
          item_sizes (
            sizes (*)
          ),
          item_add_ons (
            add_ons (*)
          )
        ''')
        .order('id', ascending: false);

    return (response as List)
        .map((json) => MenuItemModel.fromJson(json))
        .toList();
  }

  /// Fetch master list of sizes
  Future<List<SizeModel>> getSizes() async {
    final response = await _supabase.from('sizes').select().order('id');
    return (response as List).map((json) => SizeModel.fromJson(json)).toList();
  }

  /// Fetch master list of add-ons
  Future<List<AddOnModel>> getAddOns() async {
    final response = await _supabase
        .from('add_ons')
        .select()
        .eq('is_available', true)
        .order('name');

    return (response as List).map((json) => AddOnModel.fromJson(json)).toList();
  }

  // ==========================================
  // CREATE / UPDATE / DELETE METHODS
  // ==========================================

  /// Insert a new menu item and link selected sizes & add-ons
  Future<void> createMenuItem({
    required int categoryId,
    required String name,
    required double price,
    String? imagePath,
    required List<int> sizeIds,
    required List<int> addOnIds,
  }) async {
    // 1. Insert Menu Item
    final insertedItem = await _supabase
        .from('menu_items')
        .insert({
          'category_id': categoryId,
          'name': name,
          'price': price,
          'image_path': imagePath,
        })
        .select()
        .single();

    final newItemId = insertedItem['id'] as int;

    // 2. Attach Sizes in Pivot Table
    if (sizeIds.isNotEmpty) {
      final sizeRows = sizeIds
          .map((sId) => {'menu_item_id': newItemId, 'size_id': sId})
          .toList();
      await _supabase.from('item_sizes').insert(sizeRows);
    }

    // 3. Attach Add-Ons in Pivot Table
    if (addOnIds.isNotEmpty) {
      final addOnRows = addOnIds
          .map((aId) => {'menu_item_id': newItemId, 'add_on_id': aId})
          .toList();
      await _supabase.from('item_add_ons').insert(addOnRows);
    }
  }

  /// Toggle Item Availability (In-stock / Out-of-stock)
  Future<void> toggleAvailability(int menuItemId, bool currentStatus) async {
    await _supabase
        .from('menu_items')
        .update({'is_available': !currentStatus})
        .eq('id', menuItemId);
  }

  /// Toggle Featured Status
  Future<void> toggleFeatured(int menuItemId, bool currentStatus) async {
    await _supabase
        .from('menu_items')
        .update({'is_featured': !currentStatus})
        .eq('id', menuItemId);
  }

  /// Delete Menu Item
  Future<void> deleteMenuItem(int menuItemId) async {
    await _supabase.from('menu_items').delete().eq('id', menuItemId);
  }

  /// Uploads an image file to Supabase Storage bucket 'menu_items' and returns its public URL
  Future<String?> uploadMenuItemImage(File imageFile) async {
    try {
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'items/$fileName';

      await _supabase.storage
          .from('menu_items')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL for the uploaded file
      final publicUrl = _supabase.storage.from('menu_items').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Image Upload Error: $e');
      rethrow;
    }
  }
}
