import 'dart:io';
import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/category_model.dart';
import 'package:the_legit_smoothie/features/store/models/menu_item_model.dart';
import 'package:the_legit_smoothie/features/store/services/menu_database_service.dart';

class MenuManagementView extends StatefulWidget {
  final Color primaryAccent;
  final bool isDarkMode;
  final VoidCallback? onAddItemPressed;
  final ValueChanged<int>? onActiveCountChanged; // <-- 1. Active count callback

  const MenuManagementView({
    super.key,
    required this.primaryAccent,
    required this.isDarkMode,
    this.onAddItemPressed,
    this.onActiveCountChanged, // <-- 1. Active count callback
  });

  @override
  State<MenuManagementView> createState() => MenuManagementViewState();
}

class MenuManagementViewState extends State<MenuManagementView> {
  final MenuDatabaseService _databaseService = MenuDatabaseService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<CategoryModel> _dbCategories = [];
  List<MenuItemModel> _menuItems = [];

  @override
  void initState() {
    super.initState();
    loadMenuData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper to send current active count to parent components (e.g. StoreHeader)
  void _notifyActiveCount() {
    final activeCount = _menuItems.where((item) => item.isAvailable).length;
    widget.onActiveCountChanged?.call(activeCount);
  }

  /// Fetches categories and menu items directly from the Database
  Future<void> loadMenuData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _databaseService.getCategories(),
        _databaseService.getMenuItems(),
      ]);

      if (!mounted) return;

      setState(() {
        _dbCategories = results[0] as List<CategoryModel>;
        _menuItems = results[1] as List<MenuItemModel>;
        _isLoading = false;
      });

      // Notify parent of initial active count
      _notifyActiveCount();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading menu from database: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Toggles availability status and updates Database
  Future<void> _toggleAvailability(MenuItemModel item) async {
    final int itemIndex = _menuItems.indexWhere((m) => m.id == item.id);
    if (itemIndex == -1) return;

    final bool currentStatus = item.isAvailable;
    final bool newStatus = !currentStatus;

    // Optimistic UI Update using copyWith
    setState(() {
      _menuItems[itemIndex] = item.copyWith(isAvailable: newStatus);
    });

    // Instantly reflect active count in parent UI
    _notifyActiveCount();

    try {
      await _databaseService.toggleAvailability(item.id, currentStatus);
    } catch (e) {
      // Rollback on failure
      if (mounted) {
        setState(() {
          _menuItems[itemIndex] = item.copyWith(isAvailable: currentStatus);
        });
        
        // Rollback active count in parent UI
        _notifyActiveCount();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update availability: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(widget.isDarkMode ? 0.65 : 0.85);
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (widget.isDarkMode ? Colors.white : AppColors.darkText);
    final subTextColor = widget.isDarkMode
        ? AppColors.cream.withOpacity(0.6)
        : AppColors.greyText;

    // Combine 'All' category with database categories
    final List<String> categoryNames = [
      'All',
      ..._dbCategories.map((c) => c.name),
    ];

    // Filter items based on active category and search input
    final filteredItems = _menuItems.where((item) {
      final categoryName = item.category?.name ?? '';
      final categoryMatch =
          _selectedCategory == 'All' ||
          categoryName.toLowerCase() == _selectedCategory.toLowerCase();

      final searchMatch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          categoryName.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: CircularProgressIndicator(color: widget.primaryAccent),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Bar Header
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search database items...',
                    hintStyle: TextStyle(color: subTextColor, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: subTextColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: subTextColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: widget.primaryAccent,
                  size: 20,
                ),
                onPressed: loadMenuData,
                tooltip: 'Refresh Menu',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Dynamic DB Category Filter Tabs
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categoryNames.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categoryNames[index];
              final isSel =
                  cat.toLowerCase() == _selectedCategory.toLowerCase();

              return InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel ? widget.primaryAccent : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel
                          ? widget.primaryAccent
                          : theme.dividerColor.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel
                          ? (widget.isDarkMode
                              ? AppColors.darkText
                              : Colors.white)
                          : textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // 3. Menu Grid View
        filteredItems.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 48,
                      color: subTextColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No products found in database',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try adding items or changing filters.',
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Availability Status & Edit Icon Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (item.isAvailable
                                            ? AppColors.success
                                            : AppColors.error)
                                        .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.isAvailable ? 'Available' : 'Sold Out',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: item.isAvailable
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Handle edit item action here
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: widget.primaryAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  color: widget.primaryAccent,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Image Container
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: widget.isDarkMode
                                  ? Colors.black.withOpacity(0.15)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: _buildItemImage(
                                  item.imagePath,
                                  widget.primaryAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Category Name Sub-label
                        if (item.category?.name != null &&
                            item.category!.name.isNotEmpty) ...[
                          Text(
                            item.category!.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: widget.isDarkMode
                                  ? AppColors.cream.withOpacity(0.5)
                                  : AppColors.greyText,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],

                        // Title
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Price & Availability Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₱${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.secondary,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.75,
                              child: Switch.adaptive(
                                value: item.isAvailable,
                                activeColor: widget.primaryAccent,
                                onChanged: (_) => _toggleAvailability(item),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  /// Helper to display DB images
  Widget _buildItemImage(String? imagePath, Color fallbackColor) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildPlaceholder(fallbackColor),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildPlaceholder(fallbackColor),
          );
        }
      }
    }

    return _buildPlaceholder(fallbackColor);
  }

  Widget _buildPlaceholder(Color fallbackColor) {
    return Container(
      color: fallbackColor.withOpacity(0.12),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Icon(Icons.fastfood_rounded, size: 32, color: fallbackColor),
    );
  }
}