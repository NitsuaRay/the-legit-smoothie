import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SellerOrderFilter {
  final String id;
  final String label;

  const SellerOrderFilter({
    required this.id,
    required this.label,
  });
}

class SellerOrdersFilterBar extends StatelessWidget {
  final List<SellerOrderFilter> filters;
  final String selectedFilter;
  final int Function(String filterId) countForFilter;
  final ValueChanged<String> onChanged;

  const SellerOrdersFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.countForFilter,
    required this.onChanged,
  });

  // ============================================================
  // FILTER ICON
  // ============================================================

  IconData _iconForFilter(String id) {
    switch (id) {
      case 'active':
        return Icons.bolt_rounded;

      case 'past':
        return Icons.history_rounded;

      case 'all':
      default:
        return Icons.grid_view_rounded;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: List.generate(
          filters.length,
          (index) {
            final filter = filters[index];

            final bool selected =
                selectedFilter == filter.id;

            final int count =
                countForFilter(filter.id);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right:
                      index < filters.length - 1
                          ? 8
                          : 0,
                ),
                child: _buildFilter(
                  filter: filter,
                  count: count,
                  selected: selected,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FILTER ITEM
  // ============================================================

  Widget _buildFilter({
    required SellerOrderFilter filter,
    required int count,
    required bool selected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selected
            ? null
            : () => onChanged(filter.id),
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 220,
          ),
          curve: Curves.easeOutCubic,
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.textPrimary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.border.withValues(
                      alpha: 0.42,
                    ),
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.018,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              // =================================================
              // ICON
              // =================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(
                          alpha: 0.12,
                        )
                      : AppColors.background,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconForFilter(filter.id),
                  size: 13,
                  color: selected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(width: 7),

              // =================================================
              // LABEL
              // =================================================

              Flexible(
                child: Text(
                  filter.label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: -0.05,
                    color: selected
                        ? Colors.white
                        : AppColors
                            .textSecondary,
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // =================================================
              // COUNT
              // =================================================

              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                constraints:
                    const BoxConstraints(
                  minWidth: 21,
                  minHeight: 21,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(
                          alpha: 0.14,
                        )
                      : AppColors.background,
                  borderRadius:
                      BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withValues(
                            alpha: 0.06,
                          )
                        : AppColors.border
                            .withValues(
                            alpha: 0.20,
                          ),
                  ),
                ),
                child: Center(
                  child: Text(
                    count > 99
                        ? '99+'
                        : '$count',
                    style: TextStyle(
                      fontSize: 7.5,
                      height: 1,
                      fontWeight:
                          FontWeight.w900,
                      color: selected
                          ? Colors.white
                          : AppColors
                              .textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}