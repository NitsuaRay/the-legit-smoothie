import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/seller/views/tabs/menu_tab/menu_management_view.dart';
import 'package:the_legit_smoothie/features/seller/views/tabs/menu_tab/store_header.dart';
import 'package:the_legit_smoothie/features/widgets/add_item_screen.dart';

class SellerMenuTab extends StatefulWidget {
  const SellerMenuTab({super.key});

  @override
  State<SellerMenuTab> createState() => _SellerMenuTabState();
}

class _SellerMenuTabState extends State<SellerMenuTab> {
  // GlobalKey to trigger loadMenuData() inside MenuManagementView when an item is added
  final GlobalKey<MenuManagementViewState> _menuKey =
      GlobalKey<MenuManagementViewState>();

  int _activeCount = 0;

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
              // 1. Header with Add Item action button
              StoreHeader(
                activeCount: _activeCount,
                onActionPressed: _openAddItemModal,
                primaryAccent: primaryAccent,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 20),

              // 2. Direct Menu Management View
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
            ],
          ),
        ),
      ),
    );
  }
}