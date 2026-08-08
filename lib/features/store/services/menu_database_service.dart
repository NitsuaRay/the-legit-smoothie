import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/add_on_model.dart';
import '../models/size_model.dart';
import '../models/flavor_model.dart';
import '../models/menu_item_model.dart';
import '../models/featured_item_model.dart';

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

  /// Fetch all menu items along with their joined categories, sizes, add-ons, and flavors
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
          ),
          item_flavors (
            flavors (*)
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

  /// Fetch master list of flavors
  Future<List<FlavorModel>> getFlavors() async {
    final response = await _supabase
        .from('flavors')
        .select()
        .eq('is_available', true)
        .order('name');

    return (response as List)
        .map((json) => FlavorModel.fromJson(json))
        .toList();
  }

  // ==========================================
  // FEATURED ITEMS METHODS (3-SLOT ARCHITECTURE)
  // ==========================================

  /// Deletes a record from the `featured_items` table by its primary key ID
  Future<void> removeFeaturedItem(int featuredId) async {
    try {
      await _supabase.from('featured_items').delete().eq('id', featuredId);
    } catch (e) {
      throw Exception('Failed to delete featured item from Supabase: $e');
    }
  }

  /// Fetches all featured item slots joined with their corresponding `menu_items` data
  Future<List<FeaturedItemModel>> getFeaturedItems() async {
    try {
      final List<dynamic> response = await _supabase
          .from('featured_items')
          .select('*, menu_items(*, categories(*))')
          .order('slot_number', ascending: true)
          .order('display_order', ascending: true);

      return response
          .map(
            (json) => FeaturedItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured items: $e');
    }
  }

  /// Assign or replace an item in a specific featured slot
  Future<void> assignFeaturedSlot({
    required int menuItemId,
    required int slotNumber,
    int displayOrder = 1,
    String? customBadge,
  }) async {
    // Upsert into featured_items table
    await _supabase.from('featured_items').upsert({
      'menu_item_id': menuItemId,
      'slot_number': slotNumber,
      'display_order': displayOrder,
      'custom_badge': customBadge,
      'is_active': true,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'menu_item_id');
  }

  /// Remove an item from the featured list by menu_item_id
  Future<void> removeFeaturedSlotByMenuItem(int menuItemId) async {
    await _supabase
        .from('featured_items')
        .delete()
        .eq('menu_item_id', menuItemId);
  }

  /// Clear an entire slot number (e.g., clear all Carousel items in Slot 3)
  Future<void> clearFeaturedSlot(int slotNumber) async {
    await _supabase
        .from('featured_items')
        .delete()
        .eq('slot_number', slotNumber);
  }

  // ==========================================
  // CREATE / UPDATE / DELETE METHODS
  // ==========================================

  /// Insert a new menu item and link selected sizes, add-ons, & flavors
  Future<void> createMenuItem({
    required int categoryId,
    required String name,
    required double price,
    String? imagePath,
    required List<int> sizeIds,
    required List<int> addOnIds,
    required List<int> flavorIds,
    required bool isAvailable,
  }) async {
    // 1. Insert Menu Item
    final insertedItem = await _supabase
        .from('menu_items')
        .insert({
          'category_id': categoryId,
          'name': name,
          'price': price,
          'image_path': imagePath,
          'is_available': isAvailable,
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

    // 4. Attach Flavors in Pivot Table
    if (flavorIds.isNotEmpty) {
      final flavorRows = flavorIds
          .map((fId) => {'menu_item_id': newItemId, 'flavor_id': fId})
          .toList();
      await _supabase.from('item_flavors').insert(flavorRows);
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
