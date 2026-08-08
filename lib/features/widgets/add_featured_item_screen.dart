import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/store/models/menu_item_model.dart';
import 'package:the_legit_smoothie/features/store/services/menu_database_service.dart';

class AddFeaturedItemScreen extends StatefulWidget {
  final List<MenuItemModel> menuItems;

  const AddFeaturedItemScreen({
    super.key,
    required this.menuItems,
  });

  @override
  State<AddFeaturedItemScreen> createState() => _AddFeaturedItemScreenState();
}

class _AddFeaturedItemScreenState extends State<AddFeaturedItemScreen> {
  final MenuDatabaseService _dbService = MenuDatabaseService();

  late List<MenuItemModel> _items;
  String _searchQuery = '';
  bool _isLoading = true;

  // Local Slot State
  MenuItemModel? _slot1Item; // Slot 1: Daily Spotlight Hero (Max 1)
  final List<MenuItemModel> _slot2Items = []; // Slot 2: Featured Grid (Max 3)
  final List<MenuItemModel> _slot3Items = []; // Slot 3: Hero Carousel (Max 5)

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.menuItems);
    _loadFeaturedSlots();
  }

  /// Load active featured items directly from Supabase via MenuDatabaseService
  Future<void> _loadFeaturedSlots() async {
    try {
      final featuredItems = await _dbService.getFeaturedItems();

      setState(() {
        _slot1Item = null;
        _slot2Items.clear();
        _slot3Items.clear();

        for (var featured in featuredItems) {
          final item = featured.menuItem;
          if (item == null) continue;

          if (featured.slotNumber == 1) {
            _slot1Item = item;
          } else if (featured.slotNumber == 2 && _slot2Items.length < 3) {
            _slot2Items.add(item);
          } else if (featured.slotNumber == 3 && _slot3Items.length < 5) {
            _slot3Items.add(item);
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load featured items: $e')),
        );
      }
    }
  }

  /// Helper to check if an item is assigned to any slot locally
  int? _getItemSlot(int itemId) {
    if (_slot1Item?.id == itemId) return 1;
    if (_slot2Items.any((e) => e.id == itemId)) return 2;
    if (_slot3Items.any((e) => e.id == itemId)) return 3;
    return null;
  }

  List<MenuItemModel> get _filteredItems {
    if (_searchQuery.trim().isEmpty) return _items;
    return _items.where((item) {
      final nameMatches =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final categoryMatches = item.category?.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      return nameMatches || categoryMatches;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // DB SYNC & SLOT ASSIGNMENTS
  // ---------------------------------------------------------------------------

  Future<void> _assignToSlot1(MenuItemModel item) async {
    final previousSlot1 = _slot1Item;

    setState(() {
      _slot1Item = item;
      // Remove from other slots if it was previously assigned elsewhere
      _slot2Items.removeWhere((e) => e.id == item.id);
      _slot3Items.removeWhere((e) => e.id == item.id);
    });

    try {
      // If previous Slot 1 item existed, remove it in DB or overwrite
      if (previousSlot1 != null && previousSlot1.id != item.id) {
        await _dbService.removeFeaturedSlotByMenuItem(previousSlot1.id);
      }
      await _dbService.assignFeaturedSlot(
        menuItemId: item.id,
        slotNumber: 1,
        displayOrder: 1,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update Slot 1: $e');
    }
  }

  Future<void> _assignToSlot2(MenuItemModel item) async {
    if (_slot2Items.any((e) => e.id == item.id)) return;

    setState(() {
      if (_slot1Item?.id == item.id) _slot1Item = null;
      _slot3Items.removeWhere((e) => e.id == item.id);

      if (_slot2Items.length >= 3) {
        final removed = _slot2Items.removeAt(0);
        _dbService.removeFeaturedSlotByMenuItem(removed.id);
      }
      _slot2Items.add(item);
    });

    try {
      await _dbService.assignFeaturedSlot(
        menuItemId: item.id,
        slotNumber: 2,
        displayOrder: _slot2Items.length,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update Slot 2: $e');
    }
  }

  Future<void> _assignToSlot3(MenuItemModel item) async {
    if (_slot3Items.any((e) => e.id == item.id)) return;

    setState(() {
      if (_slot1Item?.id == item.id) _slot1Item = null;
      _slot2Items.removeWhere((e) => e.id == item.id);

      if (_slot3Items.length >= 5) {
        final removed = _slot3Items.removeAt(0);
        _dbService.removeFeaturedSlotByMenuItem(removed.id);
      }
      _slot3Items.add(item);
    });

    try {
      await _dbService.assignFeaturedSlot(
        menuItemId: item.id,
        slotNumber: 3,
        displayOrder: _slot3Items.length,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to update Slot 3: $e');
    }
  }

  Future<void> _removeFromSlot(MenuItemModel item, int slotNumber) async {
    setState(() {
      if (slotNumber == 1 && _slot1Item?.id == item.id) {
        _slot1Item = null;
      } else if (slotNumber == 2) {
        _slot2Items.removeWhere((e) => e.id == item.id);
      } else if (slotNumber == 3) {
        _slot3Items.removeWhere((e) => e.id == item.id);
      }
    });

    try {
      await _dbService.removeFeaturedSlotByMenuItem(item.id);
    } catch (e) {
      _showErrorSnackBar('Failed to remove item: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILDERS
  // ---------------------------------------------------------------------------

  void _showSlotSelectionSheet(
      BuildContext context, MenuItemModel item, Color primaryAccent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkText : AppColors.cardWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign "${item.name}"',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.cream : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select which layout section to display this item in:',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.cream.withOpacity(0.7)
                      : AppColors.greyText,
                ),
              ),
              const SizedBox(height: 16),

              // Slot 1
              _buildSlotPickerOption(
                context,
                title: 'Slot 1: ⚡ Daily Spotlight Hero (1 Item)',
                subtitle: _slot1Item != null
                    ? 'Currently: ${_slot1Item!.name} (Will replace)'
                    : 'Hero spotlight banner',
                icon: Icons.bolt_rounded,
                accent: primaryAccent,
                onTap: () {
                  Navigator.pop(context);
                  _assignToSlot1(item);
                },
              ),
              const SizedBox(height: 10),

              // Slot 2
              _buildSlotPickerOption(
                context,
                title: 'Slot 2: 🏷️ Featured Grid (${_slot2Items.length}/3 Items)',
                subtitle: 'Main grid cards under Hero banner',
                icon: Icons.grid_view_rounded,
                accent: primaryAccent,
                onTap: () {
                  Navigator.pop(context);
                  _assignToSlot2(item);
                },
              ),
              const SizedBox(height: 10),

              // Slot 3
              _buildSlotPickerOption(
                context,
                title: 'Slot 3: 🎠 Hero Carousel (${_slot3Items.length}/5 Items)',
                subtitle: 'Horizontal sliding carousel cards',
                icon: Icons.view_carousel_rounded,
                accent: primaryAccent,
                onTap: () {
                  Navigator.pop(context);
                  _assignToSlot3(item);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotPickerOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.bobaBrown.withOpacity(0.5)
                : AppColors.greyBorder,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accent.withOpacity(0.2),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.cream : AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.cream.withOpacity(0.6)
                          : AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDark ? AppColors.cream : AppColors.greyText),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final cardColor = isDarkMode
        ? AppColors.darkText.withOpacity(0.85)
        : AppColors.cardWhite.withOpacity(0.92);
    final textColor = isDarkMode ? AppColors.cream : AppColors.darkText;
    final subtextColor =
        isDarkMode ? AppColors.cream.withOpacity(0.7) : AppColors.greyText;
    final borderColor = isDarkMode
        ? AppColors.bobaBrown.withOpacity(0.5)
        : AppColors.greyBorder;

    final bgImagePath =
        isDarkMode ? 'assets/bgBrown.png' : 'assets/bgWhite.png';

    return Container(
      color: isDarkMode ? AppColors.darkText : AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Featured Slot Allocations',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryAccent))
              : Column(
                  children: [
                    // 1. TOP SLOTS PREVIEW SECTION
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SLOT 1
                            _buildSlotHeader(
                              title: 'SLOT 1: Daily Spotlight Hero',
                              countText:
                                  _slot1Item != null ? '1/1 Selected' : '0/1',
                              accent: primaryAccent,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 6),
                            if (_slot1Item != null)
                              _buildSelectedItemChip(
                                item: _slot1Item!,
                                slotNum: 1,
                                cardColor: cardColor,
                                borderColor: borderColor,
                                textColor: textColor,
                              )
                            else
                              _buildEmptySlotBanner(
                                  'Tap an item below to set Hero',
                                  cardColor,
                                  borderColor,
                                  subtextColor),

                            const SizedBox(height: 16),

                            // SLOT 2
                            _buildSlotHeader(
                              title: 'SLOT 2: Featured Grid',
                              countText: '${_slot2Items.length}/3 Selected',
                              accent: primaryAccent,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 6),
                            if (_slot2Items.isNotEmpty)
                              Column(
                                children: _slot2Items
                                    .map((item) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 6.0),
                                          child: _buildSelectedItemChip(
                                            item: item,
                                            slotNum: 2,
                                            cardColor: cardColor,
                                            borderColor: borderColor,
                                            textColor: textColor,
                                          ),
                                        ))
                                    .toList(),
                              )
                            else
                              _buildEmptySlotBanner(
                                  'No items in Slot 2 grid',
                                  cardColor,
                                  borderColor,
                                  subtextColor),

                            const SizedBox(height: 16),

                            // SLOT 3
                            _buildSlotHeader(
                              title: 'SLOT 3: Hero Carousel Slider',
                              countText: '${_slot3Items.length}/5 Selected',
                              accent: primaryAccent,
                              textColor: textColor,
                            ),
                            const SizedBox(height: 6),
                            if (_slot3Items.isNotEmpty)
                              SizedBox(
                                height: 48,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _slot3Items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final item = _slot3Items[idx];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            item.name,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: textColor),
                                          ),
                                          const SizedBox(width: 4),
                                          InkWell(
                                            onTap: () =>
                                                _removeFromSlot(item, 3),
                                            child: const Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              _buildEmptySlotBanner(
                                  'No carousel items selected',
                                  cardColor,
                                  borderColor,
                                  subtextColor),
                          ],
                        ),
                      ),
                    ),

                    Divider(color: borderColor, height: 1),

                    // 2. SEARCH & ITEM LIST
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(color: textColor, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search items to assign to slots...',
                          hintStyle:
                              TextStyle(color: subtextColor, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: primaryAccent, size: 20),
                          filled: true,
                          fillColor: cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: primaryAccent, width: 1.5),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 4,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                        itemCount: _filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final assignedSlot = _getItemSlot(item.id);
                          final isAssigned = assignedSlot != null;

                          return Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isAssigned ? primaryAccent : borderColor,
                                width: isAssigned ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                '₱${item.price.toStringAsFixed(2)} • ${item.category?.name ?? 'General'}${isAssigned ? " • Assigned to Slot $assignedSlot" : ""}',
                                style:
                                    TextStyle(color: subtextColor, fontSize: 11),
                              ),
                              trailing: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isAssigned
                                      ? Colors.amber.withOpacity(0.2)
                                      : primaryAccent.withOpacity(0.15),
                                  foregroundColor: isAssigned
                                      ? Colors.amber.shade800
                                      : primaryAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                ),
                                icon: Icon(
                                  isAssigned
                                      ? Icons.star_rounded
                                      : Icons.add_circle_outline_rounded,
                                  size: 15,
                                ),
                                label: Text(
                                  isAssigned
                                      ? 'Slot $assignedSlot'
                                      : 'Assign Slot',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  _showSlotSelectionSheet(
                                      context, item, primaryAccent);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSlotHeader({
    required String title,
    required String countText,
    required Color accent,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          countText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedItemChip({
    required MenuItemModel item,
    required int slotNum,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.name} (₱${item.price.toStringAsFixed(2)})',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
          InkWell(
            onTap: () => _removeFromSlot(item, slotNum),
            child: const Icon(Icons.close_rounded,
                size: 18, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotBanner(
      String text, Color cardColor, Color borderColor, Color subtextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, style: BorderStyle.solid),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: subtextColor,
        ),
      ),
    );
  }
}