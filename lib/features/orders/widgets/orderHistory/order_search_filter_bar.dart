import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilter;
  final List<Map<String, dynamic>> filterOptions;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onClearSearch;

  const OrderSearchFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onFilterSelected,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Column(
        children: [
          _SearchField(
            controller: searchController,
            hasQuery: searchQuery.isNotEmpty,
            onClear: onClearSearch,
          ),

          const SizedBox(height: 12),

          _FilterSelector(
            options: filterOptions,
            selectedFilter: selectedFilter,
            onSelected: onFilterSelected,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search your orders',
          hintStyle: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(alpha: 0.55),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
              left: 6,
              right: 2,
            ),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 50,
          ),
          suffixIcon: hasQuery
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onClear,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const _FilterSelector({
    required this.options,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: options.map((option) {
          final String key = option['key'] as String;
          final String label = option['label'] as String;
          final IconData icon = option['icon'] as IconData;

          final bool selected = selectedFilter == key;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: option != options.last ? 4 : 0,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelected(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[
                        Icon(
                          icon,
                          size: 14,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                      ],

                        Flexible(
                          child: Text(
                            _shortLabel(label),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.1,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _shortLabel(String label) {
    switch (label.toLowerCase()) {
      case 'active orders':
        return 'Active';

      case 'past orders':
        return 'Past';

      case 'all orders':
        return 'All';

      default:
        return label;
    }
  }
}