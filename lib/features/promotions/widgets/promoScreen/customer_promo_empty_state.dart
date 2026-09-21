import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoEmptyState
    extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onClearSearch;

  const CustomerPromoEmptyState({
    super.key,
    required this.hasSearch,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        28,
        18,
        40,
      ),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 34,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.border
                .withValues(
              alpha: 0.28,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color:
                    AppColors.background,
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
              ),
              child: Icon(
                hasSearch
                    ? Icons
                        .search_off_rounded
                    : Icons
                        .local_offer_outlined,
                size: 23,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              hasSearch
                  ? 'No matching deals'
                  : 'No deals right now',
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.3,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              hasSearch
                  ? 'Try another product, category, or promotion name.'
                  : 'New offers will appear here when they become available.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.45,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.70,
                ),
              ),
            ),

            if (hasSearch) ...[
              const SizedBox(height: 16),

              OutlinedButton(
                onPressed:
                    onClearSearch,
                style: OutlinedButton
                    .styleFrom(
                  foregroundColor:
                      AppColors
                          .textPrimary,
                  side: BorderSide(
                    color: AppColors
                        .border
                        .withValues(
                      alpha: 0.45,
                    ),
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      13,
                    ),
                  ),
                ),
                child: const Text(
                  'Clear search',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}