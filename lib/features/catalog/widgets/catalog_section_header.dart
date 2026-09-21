import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CatalogSectionHeader
    extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? meta;
  final double topSpacing;
  final double bottomSpacing;

  const CatalogSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.meta,
    this.topSpacing = 22,
    this.bottomSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        topSpacing,
        AppConstants.defaultPadding,
        bottomSpacing,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.58,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.4,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          if (meta != null &&
              meta!.trim().isNotEmpty) ...[
            const SizedBox(width: 12),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
              child: Text(
                meta!,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w800,
                  color: AppColors
                      .textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}