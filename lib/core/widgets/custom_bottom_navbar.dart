import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

enum UserRole { admin, seller, customer }

class CustomNavBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const CustomNavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  // Role-based Nav Item Configurations
  List<CustomNavBarItem> _getItemsForRole() {
    switch (role) {
      case UserRole.admin:
        return const [
          CustomNavBarItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          CustomNavBarItem(
            icon: Icons.store_outlined,
            selectedIcon: Icons.store_rounded,
            label: 'Store',
          ),
          CustomNavBarItem(
            icon: Icons.people_outline,
            selectedIcon: Icons.people_rounded,
            label: 'Users',
          ),
          CustomNavBarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ];

      case UserRole.seller:
        return const [
          CustomNavBarItem(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics_rounded,
            label: 'Analytics',
          ),
          CustomNavBarItem(
            icon: Icons.restaurant_menu_outlined,
            selectedIcon: Icons.restaurant_menu_rounded,
            label: 'Menu',
          ),
          CustomNavBarItem(
            icon: Icons.point_of_sale_outlined,
            selectedIcon: Icons.point_of_sale_rounded,
            label: 'Sales',
          ),
          CustomNavBarItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: 'Orders',
          ),
          CustomNavBarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ];

      case UserRole.customer:
        return const [
          CustomNavBarItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          CustomNavBarItem(
            icon: Icons.local_drink_outlined,
            selectedIcon: Icons.local_drink_rounded,
            label: 'Menu',
          ),
          CustomNavBarItem(
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart_rounded,
            label: 'Cart',
          ),
          CustomNavBarItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long_rounded,
            label: 'Orders',
          ),
          CustomNavBarItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _getItemsForRole();

    // Color Theme Mapping
    final navBarBackground = isDark ? AppColors.bobaBrown : AppColors.cardWhite;
    final indicatorColor = isDark
        ? AppColors.bobaBrown.withValues(alpha: 0.4)
        : AppColors.cream;
    final selectedColor = isDark ? AppColors.cream : AppColors.bobaBrown;
    final unselectedColor = isDark
        ? AppColors.cream.withValues(alpha: 0.5)
        : AppColors.greyText;

    return Container(
      decoration: BoxDecoration(
        color: navBarBackground,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.darkText.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: indicatorColor,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selectedColor,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: unselectedColor,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: selectedColor,
                size: 24,
              );
            }
            return IconThemeData(
              color: unselectedColor,
              size: 24,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: navBarBackground,
          elevation: 0,
          height: 65,
          destinations: items
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}