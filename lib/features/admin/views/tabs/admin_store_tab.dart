import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/featured_items_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/loyalty_program_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/menu_management_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/promos_discount_view.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_header.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/store_tab/store_nav_bar.dart';
import 'package:the_legit_smoothie/features/widgets/add_item_screen.dart';

class AdminStoreTab extends StatefulWidget {
  const AdminStoreTab({super.key});

  @override
  State<AdminStoreTab> createState() => _AdminStoreTabState();
}

class _AdminStoreTabState extends State<AdminStoreTab> {
  int _selectedTab = 0; // 0: Menu, 1: Featured, 2: Promos, 3: Loyalty

  // Centralized State
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Mango Smoothie',
      'category': 'Smoothies',
      'price': '₱120',
      'icon': '🥭',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'name': 'Brown Sugar Milk Tea',
      'category': 'Milk Tea',
      'price': '₱110',
      'icon': '🧋',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'name': 'Special Siomai Roll',
      'category': 'Snacks',
      'price': '₱75',
      'icon': '🥟',
      'isAvailable': true,
      'isFeatured': true,
    },
    {
      'name': 'Avocado Bliss',
      'category': 'Smoothies',
      'price': '₱135',
      'icon': '🥑',
      'isAvailable': false,
      'isFeatured': false,
    },
    {
      'name': 'Boba Pearls',
      'category': 'Add-ons',
      'price': '₱20',
      'icon': '🧆',
      'isAvailable': true,
      'isFeatured': false,
    },
    {
      'name': 'Strawberry Delight',
      'category': 'Smoothies',
      'price': '₱125',
      'icon': '🍓',
      'isAvailable': true,
      'isFeatured': true,
    },
  ];

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

  void _toggleAvailability(int index) {
    setState(
      () => _menuItems[index]['isAvailable'] =
          !(_menuItems[index]['isAvailable'] as bool),
    );
  }

  void _toggleFeatured(int index) {
    setState(
      () => _menuItems[index]['isFeatured'] =
          !(_menuItems[index]['isFeatured'] as bool),
    );
  }

  Future<void> _openAddItemModal() async {
    final newItem = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddItemScreen(),
    );

    if (newItem != null) {
      setState(() {
        newItem['isFeatured'] = false;
        _menuItems.insert(0, newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final availableCount = _menuItems
        .where((i) => i['isAvailable'] == true)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreHeader(
                selectedTab:
                    _selectedTab, // Pass the active index (0, 1, 2, or 3)
                activeCount: availableCount,
                onActionPressed: () {
                  switch (_selectedTab) {
                    case 0:
                      _openAddItemModal(); // Open add product modal
                      break;
                    case 1:
                      // Handle action for Featured tab
                      break;
                    case 2:
                      // Handle action for Promos tab (e.g., _openAddPromoModal())
                      break;
                    case 3:
                      // Handle action for Loyalty tab
                      break;
                  }
                },
                primaryAccent: primaryAccent,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              StoreNavBar(
                selectedTab: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
                primaryAccent: primaryAccent,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),
              IndexedStack(
                index: _selectedTab,
                children: [
                  MenuManagementView(
                    menuItems: _menuItems,
                    onToggleAvailability: _toggleAvailability,
                    onToggleFeatured: _toggleFeatured,
                    primaryAccent: primaryAccent,
                    isDarkMode: isDarkMode,
                  ),
                  FeaturedItemsView(
                    menuItems: _menuItems,
                    onToggleFeatured: _toggleFeatured,
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
