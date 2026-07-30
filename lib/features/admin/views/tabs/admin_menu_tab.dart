import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/widget/add_item_screen.dart';

class AdminMenuTab extends StatefulWidget {
  const AdminMenuTab({super.key});

  @override
  State<AdminMenuTab> createState() => _AdminMenuTabState();
}

class _AdminMenuTabState extends State<AdminMenuTab> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Smoothies',
    'Milk Tea',
    'Snacks',
    'Add-ons',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'Mango Smoothie',
      'category': 'Smoothies',
      'price': '₱120',
      'icon': '🥭',
      'isAvailable': true,
    },
    {
      'name': 'Brown Sugar Milk Tea',
      'category': 'Milk Tea',
      'price': '₱110',
      'icon': '🧋',
      'isAvailable': true,
    },
    {
      'name': 'Special Siomai Roll',
      'category': 'Snacks',
      'price': '₱75',
      'icon': '🥟',
      'isAvailable': true,
    },
    {
      'name': 'Avocado Bliss',
      'category': 'Smoothies',
      'price': '₱135',
      'icon': '🥑',
      'isAvailable': false,
    },
    {
      'name': 'Boba Pearls',
      'category': 'Add-ons',
      'price': '₱20',
      'icon': '🧆',
      'isAvailable': true,
    },
    {
      'name': 'Strawberry Delight',
      'category': 'Smoothies',
      'price': '₱125',
      'icon': '🍓',
      'isAvailable': true,
    },
  ];

  void _toggleAvailability(int index) {
    setState(() {
      _menuItems[index]['isAvailable'] =
          !(_menuItems[index]['isAvailable'] as bool);
    });
  }

  Future<void> _openAddItemModal() async {
    final newItem = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddItemScreen(),
    );

    if (newItem != null) {
      setState(() {
        _menuItems.insert(0, newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? AppColors.darkText;
    final subTextColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
        AppColors.greyText;

    final filteredItems = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems
              .where((item) => item['category'] == _selectedCategory)
              .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Add Item Action & Counter
              _buildModernHeader(textColor, subTextColor, isDarkMode),

              const SizedBox(height: 20),

              // 2. Search Bar & Filter
              _buildSearchBar(theme, isDarkMode, textColor, subTextColor),

              const SizedBox(height: 20),

              // 3. Category Filter Chips
              _buildCategorySelector(theme, isDarkMode, textColor),

              const SizedBox(height: 20),

              // 4. Menu Grid
              _buildMenuGrid(
                context,
                filteredItems,
                theme,
                isDarkMode,
                textColor,
                subTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildModernHeader(
    Color textColor,
    Color subTextColor,
    bool isDarkMode,
  ) {
    final availableCount = _menuItems
        .where((i) => i['isAvailable'] == true)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Menu Catalog',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: textColor,
                ),
              ),
            ),
            // Top Add Product Button
            Material(
              color: AppColors.bobaBrown,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _openAddItemModal,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 2),
                      Icon(
                        Icons.inventory_2_rounded, // or Icons.fastfood_rounded
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: subTextColor,
              ),
            ),
            // Active Counter Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bobaBrown.withOpacity(isDarkMode ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.bobaBrown.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$availableCount Active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bobaBrown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Search Bar ---
  Widget _buildSearchBar(
    ThemeData theme,
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.25 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search items or categories...',
                hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: subTextColor,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: theme.dividerColor.withOpacity(0.5),
          ),
          IconButton(
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.bobaBrown,
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  // --- Category Selector ---
  Widget _buildCategorySelector(
    ThemeData theme,
    bool isDarkMode,
    Color textColor,
  ) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = category),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.bobaBrown
                    : (isDarkMode ? theme.cardColor : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.bobaBrown
                      : (isDarkMode
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06)),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.bobaBrown.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.white70 : AppColors.darkText),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Menu Items Grid ---
  Widget _buildMenuGrid(
    BuildContext context,
    List<Map<String, dynamic>> items,
    ThemeData theme,
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.74,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final bool isAvailable = item['isAvailable'] as bool;
        final actualIndex = _menuItems.indexOf(item);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isAvailable ? 1.0 : 0.65,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.cream.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            item['icon'],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isAvailable
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Sold Out',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAvailable
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    item['category'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.bobaBrown.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['price'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch.adaptive(
                          value: isAvailable,
                          activeColor: AppColors.bobaBrown,
                          onChanged: (_) => _toggleAvailability(actualIndex),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
