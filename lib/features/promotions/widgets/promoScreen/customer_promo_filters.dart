import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoFilters
    extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const CustomerPromoFilters({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  static const _filters = [
    _PromoFilter(
      keyName: 'all',
      label: 'All deals',
      icon: Icons.grid_view_rounded,
    ),
    _PromoFilter(
      keyName: 'active',
      label: 'Available',
      icon: Icons.bolt_outlined,
    ),
    _PromoFilter(
      keyName: 'upcoming',
      label: 'Coming soon',
      icon: Icons.schedule_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 63,
      child: ListView.separated(
        scrollDirection:
            Axis.horizontal,
        padding:
            const EdgeInsets.fromLTRB(
          18,
          13,
          18,
          7,
        ),
        itemCount:
            _filters.length,
        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 7,
        ),
        itemBuilder:
            (context, index) {
          final filter =
              _filters[index];

          final bool selected =
              selectedFilter ==
                  filter.keyName;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  onSelected(
                filter.keyName,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 170,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration:
                    BoxDecoration(
                  color: selected
                      ? AppColors
                          .textPrimary
                      : AppColors
                          .surface,
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                  border: Border.all(
                    color: selected
                        ? AppColors
                            .textPrimary
                        : AppColors
                            .border
                            .withValues(
                            alpha: 0.32,
                          ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons
                              .check_rounded
                          : filter.icon,
                      size: 14,
                      color: selected
                          ? Colors.white
                          : AppColors
                              .textSecondary,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      filter.label,
                      style:
                          TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight
                                .w800,
                        color: selected
                            ? Colors
                                .white
                            : AppColors
                                .textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoFilter {
  final String keyName;
  final String label;
  final IconData icon;

  const _PromoFilter({
    required this.keyName,
    required this.label,
    required this.icon,
  });
}