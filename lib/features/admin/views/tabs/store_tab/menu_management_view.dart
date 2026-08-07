import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class MenuManagementView extends StatefulWidget {
  final List<Map<String, dynamic>> menuItems;
  final ValueChanged<int> onToggleAvailability;
  final ValueChanged<int> onToggleFeatured;
  final Color primaryAccent;
  final bool isDarkMode;

  const MenuManagementView({
    super.key,
    required this.menuItems,
    required this.onToggleAvailability,
    required this.onToggleFeatured,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  State<MenuManagementView> createState() => _MenuManagementViewState();
}

class _MenuManagementViewState extends State<MenuManagementView> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Smoothies', 'Milk Tea', 'Snacks', 'Add-ons'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor.withOpacity(widget.isDarkMode ? 0.65 : 0.85);
    final textColor = theme.textTheme.bodyLarge?.color ?? (widget.isDarkMode ? Colors.white : AppColors.darkText);

    final filteredItems = _selectedCategory == 'All'
        ? widget.menuItems
        : widget.menuItems.where((item) => item['category'] == _selectedCategory).toList();

    return Column(
      children: [
        // Search Input
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
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search items or categories...',
                    prefixIcon: Icon(Icons.search_rounded, size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.tune_rounded, color: widget.primaryAccent, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Category Filter List
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSel = cat == _selectedCategory;
              return InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? widget.primaryAccent : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? widget.primaryAccent : theme.dividerColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? (widget.isDarkMode ? AppColors.darkText : Colors.white) : textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Menu Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.70,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isAvailable = item['isAvailable'] as bool;
            final isFeatured = item['isFeatured'] as bool;
            final actualIndex = widget.menuItems.indexOf(item);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['icon'], style: const TextStyle(fontSize: 24)),
                      GestureDetector(
                        onTap: () => widget.onToggleFeatured(actualIndex),
                        child: Icon(
                          isFeatured ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: isFeatured ? Colors.amber[700] : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(item['name'], maxLines: 1, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['price'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch.adaptive(
                          value: isAvailable,
                          activeColor: widget.primaryAccent,
                          onChanged: (_) => widget.onToggleAvailability(actualIndex),
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
}