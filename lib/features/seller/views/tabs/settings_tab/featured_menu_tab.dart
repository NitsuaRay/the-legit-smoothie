import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class FeaturedMenuTab extends StatefulWidget {
  const FeaturedMenuTab({super.key});

  @override
  State<FeaturedMenuTab> createState() => _FeaturedMenuTabState();
}

class _FeaturedMenuTabState extends State<FeaturedMenuTab> {
  // Mock list of menu items with featured status
  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'Mango Graham Crunch',
      'category': 'Classic Smoothies',
      'price': '₱140.00',
      'rating': 4.9,
      'isFeatured': true,
      'imageIcon': Icons.local_drink_rounded,
    },
    {
      'id': '2',
      'name': 'Avocado Pearl Delight',
      'category': 'Creamy Series',
      'price': '₱160.00',
      'rating': 4.8,
      'isFeatured': true,
      'imageIcon': Icons.local_cafe_rounded,
    },
    {
      'id': '3',
      'name': 'Berry Explosion',
      'category': 'Fruit Tea & Smoothies',
      'price': '₱150.00',
      'rating': 4.7,
      'isFeatured': true,
      'imageIcon': Icons.emoji_food_beverage_rounded,
    },
    {
      'id': '4',
      'name': 'Dark Chocolate Boba',
      'category': 'Signature Milk Tea',
      'price': '₱130.00',
      'rating': 4.6,
      'isFeatured': false,
      'imageIcon': Icons.local_drink_rounded,
    },
    {
      'id': '5',
      'name': 'Matcha Green Tea Cooler',
      'category': 'Specialty Series',
      'price': '₱145.00',
      'rating': 4.5,
      'isFeatured': false,
      'imageIcon': Icons.local_cafe_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;
    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;

    final featuredItems =
        _menuItems.where((item) => item['isFeatured'] == true).toList();
    final nonFeaturedItems =
        _menuItems.where((item) => item['isFeatured'] == false).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkText : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Featured Menu Items',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Info Banner ---
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.1)
                    : AppColors.bobaBrown.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.2)
                      : AppColors.bobaBrown.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Featured items will be pinned to the top carousel on the customer homepage.',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Section 1: Active Featured Items ---
            _buildSectionHeader(
              'FEATURED ON HOMEPAGE (${featuredItems.length})',
              isDark,
            ),
            const SizedBox(height: 12),
            if (featuredItems.isEmpty)
              _buildEmptyState('No featured items selected yet.', secondaryTextColor)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: featuredItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = featuredItems[index];
                  return _buildMenuItemTile(
                    item: item,
                    cardColor: cardColor,
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  );
                },
              ),

            const SizedBox(height: 28),

            // --- Section 2: Other Menu Items ---
            _buildSectionHeader(
              'ALL OTHER ITEMS (${nonFeaturedItems.length})',
              isDark,
            ),
            const SizedBox(height: 12),
            if (nonFeaturedItems.isEmpty)
              _buildEmptyState('All items are currently featured.', secondaryTextColor)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nonFeaturedItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = nonFeaturedItems[index];
                  return _buildMenuItemTile(
                    item: item,
                    cardColor: cardColor,
                    isDark: isDark,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                  );
                },
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Menu Item Tile Widget ---
  Widget _buildMenuItemTile({
    required Map<String, dynamic> item,
    required Color cardColor,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final bool isFeatured = item['isFeatured'];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured
              ? (isDark ? AppColors.cream : AppColors.bobaBrown)
              : (isDark
                  ? AppColors.bobaBrown.withValues(alpha: 0.4)
                  : AppColors.greyBorder),
          width: isFeatured ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Beverage Icon Container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.12)
                    : AppColors.bobaBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item['imageIcon'] as IconData,
                color: isDark ? AppColors.cream : AppColors.bobaBrown,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),

            // Item Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['category'],
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        item['price'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.cream
                              : AppColors.bobaBrown,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${item['rating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Featured Toggle Switch
            Switch(
              value: isFeatured,
              activeColor: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
              activeTrackColor:
                  isDark ? AppColors.cream : AppColors.bobaBrown,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: isDark
                  ? Colors.white10
                  : AppColors.greyBorder.withValues(alpha: 0.5),
              onChanged: (value) {
                setState(() {
                  item['isFeatured'] = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: textColor.withValues(alpha: 0.7),
          fontSize: 13,
        ),
      ),
    );
  }
}