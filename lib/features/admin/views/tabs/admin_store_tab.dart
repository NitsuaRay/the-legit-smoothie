import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/featured_items_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/loyalty_program_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/menu_management_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/promos_discount_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_header.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_nav_bar.dart';
import 'package:the_legit_smoothie/features/store/models/featured_item_model.dart';
import 'package:the_legit_smoothie/features/store/models/menu_item_model.dart';
import 'package:the_legit_smoothie/features/store/services/menu_database_service.dart';
import 'package:the_legit_smoothie/features/widgets/add_featured_item_screen.dart';
import 'package:the_legit_smoothie/features/widgets/add_item_screen.dart';

class AdminStoreTab extends StatefulWidget {
  const AdminStoreTab({super.key});

  @override
  State<AdminStoreTab> createState() => _AdminStoreTabState();
}

class _AdminStoreTabState extends State<AdminStoreTab> {
  final MenuDatabaseService _menuService = MenuDatabaseService();

  // GlobalKey to trigger loadMenuData() inside MenuManagementView when an item is added
  final GlobalKey<MenuManagementViewState> _menuKey =
      GlobalKey<MenuManagementViewState>();

  int _selectedTab = 0; // 0: Menu, 1: Featured, 2: Promos, 3: Loyalty
  int _activeCount = 0;
  bool _isLoading = true;

  // Real menu items & featured items state fetched from Supabase
  List<MenuItemModel> _menuItems = [];
  List<FeaturedItemModel> _featuredList = [];

  // Promos & Loyalty program state
  final List<Map<String, dynamic>> _promos = [
    {
      'code': 'SMOOTHIESUMMER',
      'discount': '20% OFF',
      'description': 'Applicable on all Smoothies items',
      'expiry': 'Valid until Aug 31',
      'isActive': true,
    },
    {
      'code': 'WELCOMEBOBA',
      'discount': '₱30 OFF',
      'description': 'First-time customer discount',
      'expiry': 'Ongoing',
      'isActive': true,
    },
  ];

  double _pointsPerPeso = 1.0;
  bool _loyaltyEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Fetches both menu items and featured items from Supabase
  Future<void> _loadInitialData() async {
    try {
      final items = await _menuService.getMenuItems();
      final featured = await _menuService.getFeaturedItems();

      if (mounted) {
        setState(() {
          _menuItems = items;
          _featuredList = featured;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading store data: $e')));
      }
    }
  }

  /// Fetches menu items directly from Supabase
  Future<void> _fetchMenuItems() async {
    try {
      final items = await _menuService.getMenuItems();
      if (mounted) {
        setState(() {
          _menuItems = items;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu items: $e')));
      }
    }
  }

  /// Fetches featured items directly from Supabase
  Future<void> _fetchFeaturedItems() async {
    try {
      final featured = await _menuService.getFeaturedItems();
      if (mounted) {
        setState(() {
          _featuredList = featured;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading featured items: $e')),
        );
      }
    }
  }

  /// Opens the Add Item bottom sheet modal & refreshes database menu if saved
  Future<void> _openAddItemModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddItemScreen(),
    );

    if (result == true) {
      await _fetchMenuItems();
      _menuKey.currentState?.loadMenuData();
    }
  }

  /// Opens the Add/Manage Featured Items Screen
  Future<void> _openAddFeaturedItemModal() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeaturedItemScreen(menuItems: _menuItems),
      ),
    );

    // Refresh data when returning from manage screen
    await _loadInitialData();
  }

  /// Removes a featured item from the database with user confirmation
  Future<void> _removeFeaturedItem(int featuredId, [String? itemName]) async {
    // 1. Get the item name for the dialog prompt
    String title = itemName ?? '';
    if (title.isEmpty) {
      try {
        final target = _featuredList.firstWhere((e) => e.id == featuredId);
        title = target.menuItem?.name ?? 'this item';
      } catch (_) {
        title = 'this item';
      }
    }

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Check system/app brightness
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark
              ? const Color(0xFF24201D)
              : AppColors.cardWhite,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Soft Circular Icon Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(
                      alpha: isDark ? 0.2 : 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Title
                Text(
                  'Remove Featured Item',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Description
                Text(
                  'Are you sure you want to remove "$title" from featured items?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark
                        ? AppColors.cream.withValues(alpha: 0.8)
                        : AppColors.greyText,
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Action Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark
                                ? Colors.white24
                                : AppColors.greyBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white70 : AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Remove Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Remove',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // If user canceled or tapped outside the dialog, exit early
    if (shouldRemove != true) return;

    // 3. Perform removal logic
    try {
      // Optimistic state update
      setState(() {
        _featuredList.removeWhere((item) => item.id == featuredId);
      });

      // Remove from database via service
      await _menuService.removeFeaturedItem(featuredId);

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" removed from featured items.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Refresh on error to restore state
      await _fetchFeaturedItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove featured item: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryAccent))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header with dynamic action button
                    StoreHeader(
                      selectedTab: _selectedTab,
                      activeCount: _activeCount,
                      onActionPressed: () {
                        switch (_selectedTab) {
                          case 0:
                            _openAddItemModal();
                            break;
                          case 1:
                            _openAddFeaturedItemModal();
                            break;
                          case 2:
                            break;
                          case 3:
                            break;
                        }
                      },
                      primaryAccent: primaryAccent,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 16),

                    // 2. Tab Navigation Bar
                    StoreNavBar(
                      selectedTab: _selectedTab,
                      onTabChanged: (index) =>
                          setState(() => _selectedTab = index),
                      primaryAccent: primaryAccent,
                      isDarkMode: isDarkMode,
                    ),
                    const SizedBox(height: 20),

                    // 3. Indexed Tab Views
                    IndexedStack(
                      index: _selectedTab,
                      children: [
                        MenuManagementView(
                          key: _menuKey,
                          primaryAccent: primaryAccent,
                          isDarkMode: isDarkMode,
                          onAddItemPressed: _openAddItemModal,
                          onActiveCountChanged: (count) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _activeCount = count);
                              }
                            });
                          },
                        ),
                        FeaturedItemsView(
                          featuredList: _featuredList,
                          onRemoveFeatured: _removeFeaturedItem,
                          onManagePressed: _openAddFeaturedItemModal,
                          primaryAccent: primaryAccent,
                          isDarkMode: isDarkMode,
                        ),
                        PromosDiscountView(
                          promos: _promos,
                          primaryAccent: primaryAccent,
                          isDarkMode: isDarkMode,
                        ),
                        LoyaltyProgramView(
                          loyaltyEnabled: _loyaltyEnabled,
                          pointsPerPeso: _pointsPerPeso,
                          onLoyaltyToggle: (val) =>
                              setState(() => _loyaltyEnabled = val),
                          onPointsChanged: (val) =>
                              setState(() => _pointsPerPeso = val),
                          primaryAccent: primaryAccent,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
