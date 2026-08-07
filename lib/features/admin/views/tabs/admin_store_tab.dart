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
  // GlobalKey to trigger loadMenuData() inside MenuManagementView when an item is added
  final GlobalKey<MenuManagementViewState> _menuKey =
      GlobalKey<MenuManagementViewState>();

  int _selectedTab = 0; // 0: Menu, 1: Featured, 2: Promos, 3: Loyalty
  int _activeCount = 0; // <-- 1. Added active count state variable

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

    // Refresh database items in MenuManagementView if a new product was created
    if (result == true) {
      _menuKey.currentState?.loadMenuData();
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with dynamic action button
              StoreHeader(
                selectedTab: _selectedTab,
                activeCount:
                    _activeCount, // <-- 2. Replaced hardcoded '0' with state variable
                onActionPressed: () {
                  switch (_selectedTab) {
                    case 0:
                      _openAddItemModal();
                      break;
                    case 1:
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
                onTabChanged: (index) => setState(() => _selectedTab = index),
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
                      // <-- 3. Callback updates state safely after build completes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _activeCount = count);
                        }
                      });
                    },
                  ),
                  FeaturedItemsView(
                    menuItems: const [],
                    onToggleFeatured: (id) {
                      // TODO: Implement toggle featured logic here if needed
                    },
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
