import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class StoreNavBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Color primaryAccent;
  final bool isDarkMode;

  const StoreNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);

    final tabs = [
      {'label': 'Menu', 'icon': Icons.restaurant_menu_rounded},
      {'label': 'Featured', 'icon': Icons.star_rounded},
      {'label': 'Promos', 'icon': Icons.local_offer_rounded},
      {'label': 'Loyalty', 'icon': Icons.card_giftcard_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? (isDarkMode ? AppColors.darkText : Colors.white)
                          : primaryAccent.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? (isDarkMode ? AppColors.darkText : Colors.white)
                            : (isDarkMode ? Colors.white70 : AppColors.darkText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}