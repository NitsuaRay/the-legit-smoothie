import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

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
  final List<CustomNavBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Dynamic Color Mapping ---
    final navBarBackground = isDark ? AppColors.bobaBrown : AppColors.cardWhite;
    final indicatorColor = isDark 
        ? AppColors.bobaBrown.withOpacity(0.4) 
        : AppColors.cream;
    final selectedColor = isDark ? AppColors.cream : AppColors.bobaBrown;
    final unselectedColor = isDark 
        ? AppColors.cream.withOpacity(0.5) 
        : AppColors.greyText;

    return Container(
      decoration: BoxDecoration(
        color: navBarBackground,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : AppColors.darkText.withOpacity(0.06),
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