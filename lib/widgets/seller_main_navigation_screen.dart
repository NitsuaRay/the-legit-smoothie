import 'package:flutter/material.dart';

import 'package:the_legit_smoothie/features/seller/screens/seller_home_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_orders_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_products_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_profile_screen.dart';
import 'package:the_legit_smoothie/features/seller/screens/seller_promotions_screen.dart';

import '../core/constants/app_colors.dart';

class SellerMainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const SellerMainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<SellerMainNavigationScreen> createState() =>
      _SellerMainNavigationScreenState();
}

class _SellerMainNavigationScreenState
    extends State<SellerMainNavigationScreen> {
  late int _currentIndex;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex.clamp(0, 4);
  }

  // =============================================================
  // CHANGE TAB
  // =============================================================

  void _changeTab(int index) {
    if (index < 0 || index > 4) {
      return;
    }

    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  // =============================================================
  // SCREENS
  // =============================================================

  List<Widget> get _screens => [
        SellerHomeScreen(
          onNavigateToTab: _changeTab,
        ),

        const SellerProductsScreen(),

        const SellerOrdersScreen(),

        const SellerPromotionsScreen(),

        const SellerProfileScreen(),
      ];

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar:
          _buildBottomNavigationBar(),
    );
  }

  // =============================================================
  // BOTTOM NAVIGATION
  // =============================================================

  Widget _buildBottomNavigationBar() {
    final items = [
      (
        icon: Icons.dashboard_outlined,
        activeIcon:
            Icons.dashboard_rounded,
        label: 'Home',
      ),
      (
        icon:
            Icons.inventory_2_outlined,
        activeIcon:
            Icons.inventory_2_rounded,
        label: 'Products',
      ),
      (
        icon:
            Icons.receipt_long_outlined,
        activeIcon:
            Icons.receipt_long_rounded,
        label: 'Orders',
      ),
      (
        icon:
            Icons.local_offer_outlined,
        activeIcon:
            Icons.local_offer_rounded,
        label: 'Promos',
      ),
      (
        icon:
            Icons.person_outline_rounded,
        activeIcon:
            Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.06,
            ),
            blurRadius: 24,
            offset: const Offset(
              0,
              -6,
            ),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum:
            const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          10,
        ),
        child: Container(
          height: 72,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.45,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.025,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: Row(
            children:
                List.generate(
              items.length,
              (index) {
                final item =
                    items[index];

                return Expanded(
                  child: _buildNavItem(
                    icon:
                        item.icon,
                    activeIcon:
                        item.activeIcon,
                    label:
                        item.label,
                    selected:
                        _currentIndex ==
                            index,
                    onTap: () {
                      _changeTab(
                        index,
                      );
                    },
                  ),
                );
              },
            ),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 220,
        ),
        curve: Curves.easeOutCubic,
        margin:
            const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        padding:
            const EdgeInsets.symmetric(
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
                  .withValues(
                  alpha: 0.10,
                )
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(
            17,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              transitionBuilder: (
                child,
                animation,
              ) {
                return ScaleTransition(
                  scale:
                      CurvedAnimation(
                    parent:
                        animation,
                    curve: Curves
                        .easeOutBack,
                  ),
                  child: child,
                );
              },
              child: Icon(
                selected
                    ? activeIcon
                    : icon,
                key:
                    ValueKey(
                  selected,
                ),
                size:
                    selected ? 22 : 21,
                color: selected
                    ? AppColors.primary
                    : AppColors
                        .textSecondary,
              ),
            ),

            const SizedBox(
              height: 3,
            ),

            Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight:
                    selected
                        ? FontWeight
                            .w800
                        : FontWeight
                            .w600,
                color: selected
                    ? AppColors.primary
                    : AppColors
                        .textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}