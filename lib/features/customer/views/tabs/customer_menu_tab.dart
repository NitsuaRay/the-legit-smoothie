import 'package:flutter/material.dart';
import 'cart_bottom_sheet.dart';

class CustomerMenuTab extends StatefulWidget {
  const CustomerMenuTab({super.key});

  @override
  State<CustomerMenuTab> createState() => _CustomerMenuTabState();
}

class _CustomerMenuTabState extends State<CustomerMenuTab> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Custom theme colors for dark mode & icon themes
  static const Color bobaBrown = Color(0xFF3D2314);
  static const Color creamIconColor = Color(0xFFFFF8E7);

  // State: Cart Items List
  final List<Map<String, dynamic>> _cartItems = [];

  final List<String> _categories = [
    'Popular',
    'Smoothies',
    'Bowls',
    'Juices',
    'Protein',
    'Snacks',
  ];

  final List<String> _dietaryFilters = [
    'All',
    'Vegan',
    'High Protein',
    'Keto Friendly',
    'Dairy Free',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'Tropical Mango Splash',
      'category': 'Smoothies',
      'description': 'Mango, banana, coconut water, and chia seeds.',
      'price': 120.00,
      'calories': '210 kcal',
      'tags': ['Vegan', 'Dairy Free'],
      'isPopular': true,
    },
    {
      'id': '2',
      'name': 'Berry Blast Delight',
      'category': 'Smoothies',
      'description': 'Strawberries, blueberries, Greek yogurt, and honey.',
      'price': 135.00,
      'calories': '180 kcal',
      'tags': ['High Protein'],
      'isPopular': true,
    },
    {
      'id': '3',
      'name': 'Acai Energy Bowl',
      'category': 'Bowls',
      'description':
          'Acai base topped with granola, fresh banana, and peanut butter.',
      'price': 180.00,
      'calories': '320 kcal',
      'tags': ['Vegan', 'High Protein'],
      'isPopular': true,
    },
    {
      'id': '4',
      'name': 'Green Detox Booster',
      'category': 'Juices',
      'description': 'Spinach, green apple, cucumber, lemon, and ginger.',
      'price': 110.00,
      'calories': '120 kcal',
      'tags': ['Vegan', 'Keto Friendly', 'Dairy Free'],
      'isPopular': false,
    },
    {
      'id': '5',
      'name': 'Whey Power Chocolate',
      'category': 'Protein',
      'description':
          'Whey isolate, almond milk, dark cocoa, and peanut butter.',
      'price': 160.00,
      'calories': '350 kcal',
      'tags': ['High Protein', 'Keto Friendly'],
      'isPopular': true,
    },
    {
      'id': '6',
      'name': 'Oat & Nut Energy Bites',
      'category': 'Snacks',
      'description':
          'Rolled oats, chia seeds, dark chocolate chips, and almond butter.',
      'price': 85.00,
      'calories': '150 kcal',
      'tags': ['Vegan'],
      'isPopular': false,
    },
  ];

  // Cart Getters
  int get _totalCartCount =>
      _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  double get _totalCartPrice => _cartItems.fold(
        0.0,
        (sum, item) =>
            sum + ((item['price'] as double) * (item['quantity'] as int)),
      );

  List<Map<String, dynamic>> get _filteredItems {
    return _menuItems.where((item) {
      final categoryMatch = _selectedCategoryIndex == 0
          ? true
          : item['category'] == _categories[_selectedCategoryIndex];

      final filterMatch = _selectedFilter == 'All'
          ? true
          : (item['tags'] as List<String>).contains(_selectedFilter);

      final searchMatch =
          item['name'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item['description'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

      return categoryMatch && filterMatch && searchMatch;
    }).toList();
  }

  void _openCartSheet() {
    CartBottomSheet.show(
      context,
      cartItems: _cartItems,
      onUpdateQuantity: (index, newQuantity) {
        setState(() {
          _cartItems[index]['quantity'] = newQuantity;
        });
      },
      onRemoveItem: (index) {
        setState(() {
          _cartItems.removeAt(index);
        });
      },
      onCheckout: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proceeding to checkout...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final Color iconColor = isDarkMode ? creamIconColor : colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Standard Tab Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            color: iconColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menu & Drinks',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? creamIconColor : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose your fresh order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? creamIconColor.withOpacity(0.7)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _cartItems.isEmpty ? null : _openCartSheet,
                        icon: Icon(
                          Icons.shopping_bag_outlined,
                          color: isDarkMode ? creamIconColor : null,
                        ),
                      ),
                      if (_totalCartCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Badge(label: Text('$_totalCartCount')),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Search & Dietary Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  SearchBar(
                    hintText: 'Search drink menu...',
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      isDarkMode
                          ? bobaBrown.withRed(bobaBrown.red + 15)
                          : colorScheme.surfaceContainerHigh,
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    leading: Icon(
                      Icons.search_rounded,
                      color: isDarkMode ? creamIconColor : colorScheme.onSurfaceVariant,
                    ),
                    trailing: _searchQuery.isNotEmpty
                        ? [
                            IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: isDarkMode ? creamIconColor : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                          ]
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dietaryFilters.length,
                      itemBuilder: (context, index) {
                        final filter = _dietaryFilters[index];
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? (isDarkMode ? bobaBrown : colorScheme.onPrimary)
                                  : (isDarkMode ? creamIconColor : colorScheme.onSurface),
                            ),
                            selectedColor: isDarkMode ? creamIconColor : colorScheme.primary,
                            backgroundColor: Colors.transparent,
                            showCheckmark: false,
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDarkMode
                                      ? creamIconColor.withOpacity(0.4)
                                      : colorScheme.outlineVariant.withOpacity(0.5)),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode
                  ? creamIconColor.withOpacity(0.15)
                  : colorScheme.outlineVariant.withOpacity(0.3),
            ),

            // Sidebar + Grid Content
            Expanded(
              child: Row(
                children: [
                  // Category Sidebar
                  Container(
                    width: 88,
                    color: Colors.transparent,
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode
                                      ? creamIconColor.withOpacity(0.2)
                                      : colorScheme.primaryContainer)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(index),
                                  color: isDarkMode
                                      ? creamIconColor
                                      : (isSelected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant),
                                  size: 22,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _categories[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isDarkMode
                                        ? creamIconColor
                                        : (isSelected
                                            ? colorScheme.onPrimaryContainer
                                            : colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Products List
                  Expanded(
                    child: _filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.no_drinks_rounded,
                                  size: 48,
                                  color: isDarkMode
                                      ? creamIconColor.withOpacity(0.5)
                                      : colorScheme.onSurfaceVariant.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No items matched',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? creamIconColor
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildMenuItemCard(
                                context,
                                item: _filteredItems[index],
                                isDarkMode: isDarkMode,
                                iconColor: iconColor,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Cart Bar (Only shown when items are present)
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : FloatingCartBar(
              totalCount: _totalCartCount,
              totalPrice: _totalCartPrice,
              onTap: _openCartSheet,
            ),
    );
  }

  IconData _getCategoryIcon(int index) {
    switch (index) {
      case 0:
        return Icons.local_fire_department_rounded;
      case 1:
        return Icons.blender_rounded;
      case 2:
        return Icons.rice_bowl_rounded;
      case 3:
        return Icons.water_drop_rounded;
      case 4:
        return Icons.fitness_center_rounded;
      case 5:
        return Icons.cookie_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }

  Widget _buildMenuItemCard(
    BuildContext context, {
    required Map<String, dynamic> item,
    required bool isDarkMode,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: isDarkMode
          ? bobaBrown.withRed(bobaBrown.red + 12)
          : colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDarkMode
              ? creamIconColor.withOpacity(0.15)
              : colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showAddToCartBottomSheet(context, item),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? creamIconColor.withOpacity(0.12)
                          : colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_drink_rounded,
                        color: iconColor,
                        size: 38,
                      ),
                    ),
                  ),
                  if (item['isPopular'] == true)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'HOT',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDarkMode ? creamIconColor : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? creamIconColor.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₱${item['price'].toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? creamIconColor : colorScheme.primary,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              item['calories'],
                              style: TextStyle(
                                fontSize: 10,
                                color: isDarkMode
                                    ? creamIconColor.withOpacity(0.6)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: isDarkMode ? creamIconColor : null,
                            foregroundColor: isDarkMode ? bobaBrown : null,
                            minimumSize: const Size(64, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () =>
                              _showAddToCartBottomSheet(context, item),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: isDarkMode ? bobaBrown : null,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? bobaBrown : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToCartBottomSheet(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    int quantity = 1;
    String selectedSize = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? bobaBrown
          : Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final isDarkMode = theme.brightness == Brightness.dark;
            final colorScheme = theme.colorScheme;
            final iconColor = isDarkMode ? creamIconColor : colorScheme.primary;

            return Padding(
              padding: EdgeInsets.only(
                top: 12,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? creamIconColor.withOpacity(0.4)
                            : colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDarkMode ? creamIconColor : null,
                              ),
                            ),
                            Text(
                              item['calories'],
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? creamIconColor.withOpacity(0.7)
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₱${(item['price'] * quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? creamIconColor.withOpacity(0.7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    color: isDarkMode
                        ? creamIconColor.withOpacity(0.2)
                        : colorScheme.outlineVariant.withOpacity(0.5),
                  ),

                  // Size Selection
                  Text(
                    'Size',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDarkMode ? creamIconColor : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Small', 'Medium', 'Large'].map((size) {
                      final isSelected = selectedSize == size;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Center(child: Text(size)),
                            selected: isSelected,
                            selectedColor: isDarkMode
                                ? creamIconColor
                                : colorScheme.primaryContainer,
                            backgroundColor: isDarkMode
                                ? bobaBrown.withRed(bobaBrown.red + 15)
                                : null,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? (isDarkMode ? bobaBrown : colorScheme.onPrimaryContainer)
                                  : (isDarkMode ? creamIconColor : colorScheme.onSurface),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedSize = size);
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}