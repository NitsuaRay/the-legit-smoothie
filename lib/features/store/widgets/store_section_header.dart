import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  final String? trailing;
  final VoidCallback? onTrailingPressed;

  const StoreSectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.trailing,
    this.onTrailingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        30,
        18,
        13,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          // =====================================================
          // TEXT
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.05,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.55,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // TRAILING ACTION
          // =====================================================

          if (trailing != null) ...[
            const SizedBox(width: 12),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTrailingPressed,
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        trailing!,
                        style:
                            const TextStyle(
                          fontSize: 7.5,
                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing:
                              0.65,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 13,
                        color: AppColors
                            .textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}