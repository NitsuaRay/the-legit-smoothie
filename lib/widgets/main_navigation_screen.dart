import 'package:flutter/material.dart';

import 'package:the_legit_smoothie/features/cart/screens/cart_screen.dart';
import 'package:the_legit_smoothie/features/cart/services/cart_service.dart';
import 'package:the_legit_smoothie/features/catalog/screens/home_screen.dart';
import 'package:the_legit_smoothie/features/orders/screens/order_history_screen.dart';
import 'package:the_legit_smoothie/features/profile/screens/profile_screen.dart';
import 'package:the_legit_smoothie/features/store/screens/store_screen.dart';

import '../../core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final CartService _cartService = CartService();

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _currentIndex = _safeInitialIndex(widget.initialIndex);

    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);

    super.dispose();
  }

  // =============================================================
  // INITIAL INDEX
  // =============================================================

  int _safeInitialIndex(int index) {
    if (index < 0 || index > 4) {
      return 0;
    }

    return index;
  }

  // =============================================================
  // CART
  // =============================================================

  void _onCartChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // =============================================================
  // NAVIGATION
  // =============================================================

  void _changeTab(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _openMenu() {
    _changeTab(1);
  }

  // =============================================================
  // SCREENS
  // =============================================================

  List<Widget> get _screens {
    return [
      StoreScreen(onBrowseMenu: _openMenu),
      const HomeScreen(),
      const CartScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // =============================================================
  // BOTTOM NAVIGATION
  // =============================================================

  Widget _buildBottomNavigationBar() {
    final items = [
      (
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront_rounded,
        label: 'Store',
      ),
      (
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu_rounded,
        label: 'Menu',
      ),
      (
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
        label: 'Cart',
      ),
      (
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'Orders',
      ),
      (
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];

              return Expanded(
                child: _buildNavItem(
                  icon: item.icon,
                  activeIcon: item.activeIcon,
                  label: item.label,
                  selected: _currentIndex == index,
                  badgeCount: index == 2 ? _cartService.itemCount : 0,
                  onTap: () {
                    _changeTab(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // NAV ITEM
  // =============================================================

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===================================================
            // ICON
            // ===================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutBack,
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    selected ? activeIcon : icon,
                    key: ValueKey(selected),
                    size: selected ? 22 : 21,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),

                // ===============================================
                // CART BADGE
                // ===============================================
                if (badgeCount > 0)
                  Positioned(
                    right: -9,
                    top: -8,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryDark,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 3),

            // ===================================================
            // LABEL
            // ===================================================
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
