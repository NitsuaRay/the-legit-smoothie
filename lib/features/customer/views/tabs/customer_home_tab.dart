import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class CustomerHomeTab extends StatefulWidget {
  const CustomerHomeTab({super.key});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  final List<String> _categories = [
    'All',
    'Smoothies',
    'Bowls',
    'Fresh Juice',
    'Protein Shakes',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Tropical Mango Splash',
      'category': 'Smoothies',
      'price': 120.00,
      'rating': 4.8,
      'calories': '210 kcal',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Berry Blast Delight',
      'category': 'Smoothies',
      'price': 135.00,
      'rating': 4.9,
      'calories': '180 kcal',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Acai Energy Bowl',
      'category': 'Bowls',
      'price': 180.00,
      'rating': 4.7,
      'calories': '320 kcal',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Green Detox Booster',
      'category': 'Fresh Juice',
      'price': 110.00,
      'rating': 4.6,
      'calories': '120 kcal',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Whey Banana Power',
      'category': 'Protein Shakes',
      'price': 160.00,
      'rating': 4.9,
      'calories': '350 kcal',
      'image': 'assets/bgWhite.png',
    },
    {
      'name': 'Dragonfruit Glow',
      'category': 'Bowls',
      'price': 195.00,
      'rating': 4.8,
      'calories': '290 kcal',
      'image': 'assets/bgWhite.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategoryIndex == 0 ||
          product['category'] == _categories[_selectedCategoryIndex];

      final matchesSearch =
          _searchQuery.isEmpty ||
          product['name'].toString().toLowerCase().contains(_searchQuery) ||
          product['category'].toString().toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Greeting & Cart Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors
                                .cardWhite // Or your AppColors dark-mode text constant
                          : AppColors.darkText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_drink_rounded,
                        color: AppColors.secondary,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Grab a Fresh Drink',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          // Uses AppColors values depending on the current theme brightness
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors
                                    .cardWhite // Or your AppColors dark-mode text constant
                              : AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.cardWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.greyBorder),
                      ),
                    ),
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.darkText,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.bobaBrown,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: AppColors.cardWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Dynamic Search Bar with Forced AppColors Contrast
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.darkText),
            cursorColor: AppColors.secondary,
            decoration: InputDecoration(
              hintText: 'Search smoothies, bowls, juices...',
              hintStyle: const TextStyle(color: AppColors.greyText),
              prefixIcon: const Icon(Icons.search, color: AppColors.greyText),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.greyText),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.secondary,
                      ),
                      onPressed: () {},
                    ),
              filled: true,
              fillColor: AppColors.cardWhite,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.greyBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Promotional Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.bobaBrown],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bobaBrown.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cream.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Promo of the Day',
                          style: TextStyle(
                            color: AppColors.cream,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buy 1 Get 1 Free on Fruit Bowls!',
                        style: TextStyle(
                          color: AppColors.cardWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Valid until today midnight.',
                        style: TextStyle(color: AppColors.cream, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.local_offer_rounded,
                  size: 48,
                  color: AppColors.cream,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.history_rounded,
                label: 'Reorder',
                onTap: () {},
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.local_shipping_outlined,
                label: 'Track',
                onTap: () {},
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.card_giftcard_rounded,
                label: 'Rewards',
                onTap: () {},
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.favorite_border_rounded,
                label: 'Favorites',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 5. Categories Horizontal List
          Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors
                        .cardWhite // Or your AppColors dark-mode text constant
                  : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    selectedColor: AppColors.secondary,
                    backgroundColor: AppColors.cardWhite,
                    disabledColor: AppColors.cardWhite,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.cardWhite
                          : AppColors.darkText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.greyBorder,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 6. Product Grid Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategoryIndex == 0
                    ? 'Popular Items'
                    : _categories[_selectedCategoryIndex],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors
                            .cardWhite // Or your AppColors dark-mode text constant
                      : AppColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7. Product Grid with Empty State Fallback
          _filteredProducts.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.greyText,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No drinks found for "$_searchQuery"',
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.greyBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkText.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image Container
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                color: AppColors.cream.withOpacity(0.3),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        product['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.local_drink_rounded,
                                                  size: 48,
                                                  color: AppColors.secondary,
                                                ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkText.withOpacity(
                                            0.75,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 14,
                                              color: AppColors.warning,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${product['rating']}',
                                              style: const TextStyle(
                                                color: AppColors.cardWhite,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Product Details
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product['category'],
                                      style: const TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      product['calories'],
                                      style: const TextStyle(
                                        color: AppColors.greyText,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱${product['price'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.bobaBrown,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          size: 18,
                                          color: AppColors.cardWhite,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

          const SizedBox(height: 24),

          // 8. Loyalty Goal Progress Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.cream,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.bobaBrown,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3 drinks away from a free cup!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors
                                    .cardWhite // Or your AppColors dark-mode text constant
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: AppColors.cardWhite,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper builder for Quick Action Buttons
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.greyBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkText.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              // Uses AppColors values for light and dark modes
              color: isDarkMode ? AppColors.cardWhite : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
