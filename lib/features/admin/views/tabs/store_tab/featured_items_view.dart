import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/menu_item_model.dart';

class FeaturedItemsView extends StatelessWidget {
  final List<MenuItemModel> menuItems;
  final Function(int id) onToggleFeatured;
  final VoidCallback? onManagePressed;
  final Color primaryAccent;
  final bool isDarkMode;

  const FeaturedItemsView({
    super.key,
    required this.menuItems,
    required this.onToggleFeatured,
    this.onManagePressed,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Filter active featured items
    final featuredItems = menuItems.where((item) => item.isFeatured).toList();

    final textColor = isDarkMode ? AppColors.cream : AppColors.darkText;
    final subtextColor =
        isDarkMode ? AppColors.cream.withOpacity(0.7) : AppColors.greyText;
    final cardColor = isDarkMode
        ? AppColors.darkText.withOpacity(0.85)
        : AppColors.cardWhite.withOpacity(0.92);
    final borderColor = isDarkMode
        ? AppColors.bobaBrown.withOpacity(0.5)
        : AppColors.greyBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Featured Showcase',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Active on customer app (${featuredItems.length})',
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
            if (onManagePressed != null)
              TextButton.icon(
                onPressed: onManagePressed,
                style: TextButton.styleFrom(
                  backgroundColor: primaryAccent.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.tune_rounded, size: 18, color: primaryAccent),
                label: Text(
                  'Manage',
                  style: TextStyle(
                    color: primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Empty State ---
        if (featuredItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 48,
                  color: primaryAccent.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'No Featured Items Selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap "Manage" to select smoothies for the home screen spotlight.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
          )
        else ...[
          // --- TWIST 1 & 3: Hero Spotlight Card (First Featured Item) ---
          _buildHeroSpotlightCard(
            context: context,
            item: featuredItems.first,
            primaryAccent: primaryAccent,
            cardColor: cardColor,
            borderColor: borderColor,
            textColor: textColor,
            subtextColor: subtextColor,
          ),

          // --- TWIST 3: Grid Layout for Additional Items (#2 and #3) ---
          if (featuredItems.length > 1) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryGridCard(
                    context: context,
                    item: featuredItems[1],
                    badgeText: _getDynamicBadge(featuredItems[1], featuredItems),
                    primaryAccent: primaryAccent,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                  ),
                ),
                const SizedBox(width: 12),
                if (featuredItems.length > 2)
                  Expanded(
                    child: _buildSecondaryGridCard(
                      context: context,
                      item: featuredItems[2],
                      badgeText: _getDynamicBadge(featuredItems[2], featuredItems),
                      primaryAccent: primaryAccent,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  )
                else
                  // Empty Slot Placeholder if only 2 items are featured
                  Expanded(
                    child: InkWell(
                      onTap: onManagePressed,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline_rounded,
                                color: primaryAccent),
                            const SizedBox(height: 6),
                            Text(
                              'Add Slot #3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  /// Dynamic Smart Badging Logic (Twist 2)
  String _getDynamicBadge(MenuItemModel item, List<MenuItemModel> allFeatured) {
    final minPrice = allFeatured.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    if (item.price == minPrice) {
      return '🏷️ Best Value';
    }
    return '🐼 Panda\'s Pick';
  }

  /// 1. Hero Spotlight Card Widget
  Widget _buildHeroSpotlightCard({
    required BuildContext context,
    required MenuItemModel item,
    required Color primaryAccent,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primaryAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Banner: Daily Spotlight & Points Multiplier
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryAccent,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: AppColors.darkText),
                    SizedBox(width: 4),
                    Text(
                      'DAILY SPOTLIGHT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.darkText,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '⚡ 2x Points',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.imagePath != null && item.imagePath!.isNotEmpty
                      ? Image.network(
                          item.imagePath!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholder(primaryAccent),
                        )
                      : _placeholder(primaryAccent),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category?.name ?? 'Special Blend',
                        style: TextStyle(fontSize: 13, color: subtextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₱${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unstar Action Button
                IconButton(
                  icon: const Icon(Icons.star_rounded,
                      color: Colors.amber, size: 28),
                  tooltip: 'Remove from featured',
                  onPressed: () => onToggleFeatured(item.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Grid Card Widget (#2 & #3)
  Widget _buildSecondaryGridCard({
    required BuildContext context,
    required MenuItemModel item,
    required String badgeText,
    required Color primaryAccent,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Badge & Toggle Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryAccent,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onToggleFeatured(item.id),
                child: const Icon(Icons.star_rounded,
                    color: Colors.amber, size: 20),
              ),
            ],
          ),
          const Spacer(),

          // Name and Price
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '₱${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(Color primaryAccent) {
    return Container(
      width: 80,
      height: 80,
      color: primaryAccent.withOpacity(0.15),
      child: Icon(Icons.local_drink_rounded, color: primaryAccent, size: 36),
    );
  }
}