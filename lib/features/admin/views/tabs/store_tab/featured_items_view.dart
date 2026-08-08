import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/featured_item_model.dart';
import 'package:the_legit_smoothie/features/store/models/menu_item_model.dart';

class FeaturedItemsView extends StatefulWidget {
  final List<FeaturedItemModel> featuredList;
  final Function(int featuredId) onRemoveFeatured;
  final VoidCallback? onManagePressed;
  final Color primaryAccent;
  final bool isDarkMode;

  const FeaturedItemsView({
    super.key,
    required this.featuredList,
    required this.onRemoveFeatured,
    this.onManagePressed,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  State<FeaturedItemsView> createState() => _FeaturedItemsViewState();
}

class _FeaturedItemsViewState extends State<FeaturedItemsView> {
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only process active items from DB
    final activeFeatured = widget.featuredList
        .where((item) => item.isActive)
        .toList();

    // Group items by slot_number according to your Supabase schema
    final slot1Item = activeFeatured
        .where((e) => e.slotNumber == 1)
        .firstOrNull;
    final slot2Items = activeFeatured.where((e) => e.slotNumber == 2).toList();
    final slot3Items = activeFeatured.where((e) => e.slotNumber == 3).toList();

    final textColor = widget.isDarkMode ? AppColors.cream : AppColors.darkText;
    final subtextColor = widget.isDarkMode
        ? AppColors.cream.withOpacity(0.7)
        : AppColors.greyText;
    final cardColor = widget.isDarkMode
        ? AppColors.darkText.withOpacity(0.85)
        : AppColors.cardWhite.withOpacity(0.92);
    final borderColor = widget.isDarkMode
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
                  'Active showcase slots (${activeFeatured.length})',
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
            if (widget.onManagePressed != null)
              TextButton.icon(
                onPressed: widget.onManagePressed,
                style: TextButton.styleFrom(
                  backgroundColor: widget.primaryAccent.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: widget.primaryAccent,
                ),
                label: Text(
                  'Manage',
                  style: TextStyle(
                    color: widget.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Empty State ---
        if (activeFeatured.isEmpty)
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
                  color: widget.primaryAccent.withOpacity(0.6),
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
                  'Tap "Manage" to set featured slots from your database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subtextColor),
                ),
              ],
            ),
          )
        else ...[
          // ==================== SLOT 1: HERO SPOTLIGHT ====================
          if (slot1Item != null && slot1Item.menuItem != null) ...[
            _buildSectionHeader('Spotlight Highlight', textColor, subtextColor),
            const SizedBox(height: 8),
            _buildHeroSpotlightCard(
              context: context,
              featured: slot1Item,
              item: slot1Item.menuItem!,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            const SizedBox(height: 20),
          ],
          // ==================== SLOT 2: FEATURED ITEMS ====================
          _buildSectionHeader(
            'Featured Items (Slot #2)',
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 8),
          if (slot2Items.isNotEmpty)
            SizedBox(
              height: 180, // Reduced height so it doesn't dominate the page
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: slot2Items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final featured = slot2Items[index];
                  if (featured.menuItem == null) return const SizedBox.shrink();

                  return SizedBox(
                    width:
                        140, // Fixed compact width -> shows ~2.5 cards side-by-side!
                    child: _buildGridCard(
                      context: context,
                      featured: featured,
                      item: featured.menuItem!,
                      cardColor: cardColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  );
                },
              ),
            )
          else
            _buildEmptySlotPlaceholder(
              slotNum: 2,
              title: 'Add items to Featured Carousel',
              cardColor: cardColor,
              borderColor: borderColor,
              subtextColor: subtextColor,
            ),
          const SizedBox(height: 20),

          // ==================== SLOT 3: HERO CAROUSEL SLIDER ====================
          _buildSectionHeader(
            'Carousel Specials (Slot #3)',
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 8),
          if (slot3Items.isNotEmpty)
            _buildHeroCarouselSlider(
              slot3Items: slot3Items,
              cardColor: cardColor,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            )
          else
            _buildEmptySlotPlaceholder(
              slotNum: 3,
              title: 'Add items to Hero Carousel',
              cardColor: cardColor,
              borderColor: borderColor,
              subtextColor: subtextColor,
            ),
        ],
      ],
    );
  }

  /// Section Header helper
  Widget _buildSectionHeader(
    String title,
    Color textColor,
    Color subtextColor,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  /// 1. Hero Spotlight Card (Slot #1)
  Widget _buildHeroSpotlightCard({
    required BuildContext context,
    required FeaturedItemModel featured,
    required MenuItemModel item,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final badgeLabel = featured.customBadge ?? 'DAILY SPOTLIGHT';

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.primaryAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: widget.primaryAccent.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Banner showing Custom Badge / Slot Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.primaryAccent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: widget.isDarkMode
                          ? AppColors.darkText
                          : AppColors.cream, // <-- Fixed lowercase 'w'
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: widget.isDarkMode
                            ? AppColors.darkText
                            : AppColors.cream, // <-- Fixed lowercase 'w'
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkText,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Slot #${featured.slotNumber}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: item.imagePath != null && item.imagePath!.isNotEmpty
                      ? Image.network(
                          item.imagePath!,
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholder(size: 85, iconSize: 36),
                        )
                      : _placeholder(size: 85, iconSize: 36),
                ),
                const SizedBox(width: 14),
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
                      if (item.category?.name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.category!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '₱${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: widget.primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  tooltip: 'Remove from featured',
                  onPressed: () => widget.onRemoveFeatured(featured.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Feature Compact Card Widget (Slot #2)
  Widget _buildGridCard({
    required BuildContext context,
    required FeaturedItemModel featured,
    required MenuItemModel item,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final badgeText = featured.customBadge ?? 'FEATURED';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge & Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.primaryAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryAccent,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => widget.onRemoveFeatured(featured.id),
                borderRadius: BorderRadius.circular(12),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Item Image
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                    ? Image.network(
                        item.imagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(size: 50, iconSize: 20),
                      )
                    : _placeholder(size: 50, iconSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Item Name
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),

          // Category Name
          Text(
            item.category?.name ?? 'Special',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: subtextColor),
          ),
          const SizedBox(height: 2),

          // Price
          Text(
            '₱${item.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: widget.primaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Hero Carousel Slider Widget (Slot #3)
  Widget _buildHeroCarouselSlider({
    required List<FeaturedItemModel> slot3Items,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _carouselController,
            onPageChanged: (index) {
              setState(() => _currentCarouselPage = index);
            },
            itemCount: slot3Items.length,
            itemBuilder: (context, index) {
              final featured = slot3Items[index];
              final item = featured.menuItem;
              if (item == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.primaryAccent.withOpacity(0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryAccent.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          item.imagePath != null && item.imagePath!.isNotEmpty
                          ? Image.network(
                              item.imagePath!,
                              width: 100,
                              height: 120,
                              fit: BoxFit
                                  .contain, // <--- Scale to show full image without cropping
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(size: 100, iconSize: 40),
                            )
                          : _placeholder(size: 100, iconSize: 40),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.primaryAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (featured.customBadge ?? 'CAROUSEL')
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: widget.isDarkMode
                                    ? AppColors.darkText
                                    : AppColors
                                          .cream, // <-- Fixed lowercase 'w'
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category?.name ?? 'Special Item',
                            style: TextStyle(fontSize: 11, color: subtextColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: widget.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 26,
                      ),
                      onPressed: () => widget.onRemoveFeatured(featured.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Carousel Dot Indicators
        if (slot3Items.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slot3Items.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCarouselPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCarouselPage == index
                      ? widget.primaryAccent
                      : borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Empty Slot Placeholder Component
  Widget _buildEmptySlotPlaceholder({
    required int slotNum,
    required String title,
    required Color cardColor,
    required Color borderColor,
    required Color subtextColor,
  }) {
    return InkWell(
      onTap: widget.onManagePressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: widget.primaryAccent,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      color: widget.primaryAccent.withOpacity(0.15),
      child: Icon(
        Icons.local_drink_rounded,
        color: widget.primaryAccent,
        size: iconSize,
      ),
    );
  }
}
