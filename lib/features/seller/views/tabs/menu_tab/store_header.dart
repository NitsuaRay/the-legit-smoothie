import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class StoreHeader extends StatelessWidget {
  final int activeCount;
  final VoidCallback onActionPressed;
  final Color primaryAccent;
  final bool isDarkMode;

  const StoreHeader({
    super.key,
    required this.activeCount,
    required this.onActionPressed,
    required this.primaryAccent,
    required this.isDarkMode,
  });

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
                    child: Icon(Icons.restaurant_menu_rounded, color: primaryAccent, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Menu Catalog',
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

            // Add Menu Item Button
            Tooltip(
              message: 'Add Menu Item',
              child: Material(
                color: primaryAccent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onActionPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 18, color: iconColor),
                        const SizedBox(width: 2),
                        Icon(Icons.restaurant_menu_rounded, size: 18, color: iconColor),
                      ],
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
              'Manage pricing & item availability',
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