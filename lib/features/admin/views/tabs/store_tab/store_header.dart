import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class StoreHeader extends StatelessWidget {
  final int selectedTab; // 0: Menu, 1: Featured, 2: Promos, 3: Loyalty
  final int activeCount;
  final VoidCallback onActionPressed;
  final Color primaryAccent;
  final bool isDarkMode;

  const StoreHeader({
    super.key,
    required this.selectedTab,
    required this.activeCount,
    required this.onActionPressed,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  // Helper method to get the icon based on the active tab
  IconData _getTabIcon() {
    switch (selectedTab) {
      case 0:
        return Icons.restaurant_menu_rounded; // Menu -> Add item icon
      case 1:
        return Icons.star_rounded;        // Featured -> Star/Featured icon
      case 2:
        return Icons.local_offer_rounded;  // Promos -> Tag/Promo icon
      case 3:
        return Icons.tune_rounded;         // Loyalty -> Settings/Tune icon
      default:
        return Icons.add_rounded;
    }
  }

  // Helper tooltip/accessibility hint based on active tab
  String _getTooltipText() {
    switch (selectedTab) {
      case 0:
        return 'Add Menu Item';
      case 1:
        return 'Manage Featured Items';
      case 2:
        return 'Add Promo Code';
      case 3:
        return 'Loyalty Settings';
      default:
        return 'Add Action';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subTextColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
        (isDarkMode ? Colors.white70 : AppColors.greyText);

    final iconColor = isDarkMode ? AppColors.darkText : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Store Title Section
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.storefront_rounded, color: primaryAccent, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Store Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: primaryAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic Action Button
            Tooltip(
              message: _getTooltipText(),
              child: Material(
                color: primaryAccent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onActionPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: Row(
                        key: ValueKey<int>(selectedTab), // Keys trigger animation on tab change
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 18, color: iconColor),
                          const SizedBox(width: 2),
                          Icon(_getTabIcon(), size: 18, color: iconColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Configure menu, specials & store promotions',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryAccent.withOpacity(isDarkMode ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryAccent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$activeCount Active',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: primaryAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}