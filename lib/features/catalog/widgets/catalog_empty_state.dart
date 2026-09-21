import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CatalogEmptyState
    extends StatelessWidget {
  final String searchQuery;

  const CatalogEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final bool searching =
        searchQuery.trim().isNotEmpty;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            child: Icon(
              searching
                  ? Icons.search_off_rounded
                  : Icons
                      .inventory_2_outlined,
              size: 28,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.42,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            searching
                ? 'No matches found'
                : 'Nothing here yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -0.2,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            searching
                ? 'We couldn’t find anything matching '
                    '“${searchQuery.trim()}”. Try another search.'
                : 'There are no available products '
                    'in this category right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.72,
              ),
            ),
          ),
        ],
      ),
    );
  }
}