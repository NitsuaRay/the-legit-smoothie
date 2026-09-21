import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CatalogCategorySelector<T>
    extends StatelessWidget {
  final List<T> categories;
  final String? selectedCategoryId;

  final ValueChanged<String?>
      onCategorySelected;

  final String Function(T category)
      getCategoryId;

  final String Function(T category)
      getCategoryName;

  const CatalogCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.getCategoryId,
    required this.getCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal:
              AppConstants.defaultPadding,
        ),
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(width: 8),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              icon: Icons.grid_view_rounded,
              isSelected:
                  selectedCategoryId == null,
              onTap: () {
                onCategorySelected(null);
              },
            );
          }

          final T category =
              categories[index - 1];

          final String id =
              getCategoryId(category);

          return _CategoryChip(
            label:
                getCategoryName(category),
            isSelected:
                selectedCategoryId == id,
            onTap: () {
              onCategorySelected(id);
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip
    extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          curve: Curves.easeOut,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.surface,
            borderRadius:
                BorderRadius.circular(13),
            border: Border.all(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.border
                      .withValues(
                      alpha: 0.35,
                    ),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 10,
                      offset:
                          const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : AppColors
                          .textSecondary,
                ),

                const SizedBox(width: 6),
              ],

              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: -0.1,
                  color: isSelected
                      ? Colors.white
                      : AppColors
                          .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}