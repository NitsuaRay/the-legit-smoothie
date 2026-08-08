import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/featured_items_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/loyalty_program_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/menu_management_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/promos_discount_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_header.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_nav_bar.dart';
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

  // Real menu items state fetched from Supabase
  List<MenuItemModel> _menuItems = [];

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
    _fetchMenuItems();
  }

  /// Fetches menu items directly from Supabase
  Future<void> _fetchMenuItems() async {
    try {
      final items = await _menuService.getMenuItems();
      if (mounted) {
        setState(() {
          _menuItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu items: $e')));
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
      builder: (context) => AddFeaturedItemScreen(
        menuItems: _menuItems,
      ),
    ),
  );

  // Refresh menu items when coming back
  await _fetchMenuItems();
}
  /// Toggles featured status locally and syncs with Supabase database
  Future<void> _toggleFeaturedStatus(int itemId, bool currentStatus) async {
    try {
      // Optimistic state update
      setState(() {
        final index = _menuItems.indexWhere((item) => item.id == itemId);
        if (index != -1) {
          _menuItems[index] = _menuItems[index].copyWith(
            isFeatured: !currentStatus,
          );
        }
      });

      // Update in Supabase database
      await _menuService.toggleFeatured(itemId, currentStatus);
    } catch (e) {
      // Rollback on error
      await _fetchMenuItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update featured status: $e')),
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
                          menuItems: _menuItems,
                          onToggleFeatured: (id) {
                            final item = _menuItems.firstWhere(
                              (i) => i.id == id,
                            );
                            _toggleFeaturedStatus(id, item.isFeatured);
                          },
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
