import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesHistoryCard extends StatelessWidget {
  final String title;
  final int orderCount;
  final String total;

  const SellerSalesHistoryCard({
    super.key,
    required this.title,
    required this.orderCount,
    required this.total,
  });

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.34,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // ===================================================
            // DECORATIVE BACKGROUND
            // ===================================================

            Positioned(
              top: -35,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary.withValues(
                    alpha: 0.018,
                  ),
                ),
              ),
            ),

            // ===================================================
            // CONTENT
            // ===================================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // =============================================
                  // TOP SECTION
                  // =============================================

                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 17,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PERIOD',
                              style: TextStyle(
                                fontSize: 6.5,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.42,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -0.2,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ===========================================
                      // REVENUE
                      // ===========================================

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            'REVENUE',
                            style: TextStyle(
                              fontSize: 6.5,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.8,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.42,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            total,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -0.4,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    height: 1,
                    color: AppColors.border.withValues(
                      alpha: 0.28,
                    ),
                  ),

                  const SizedBox(height: 13),

                  // =============================================
                  // DETAILS
                  // =============================================

                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          icon: Icons
                              .check_circle_outline_rounded,
                          label: 'COMPLETED',
                          value:
                              '$orderCount ${orderCount == 1 ? 'order' : 'orders'}',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 31,
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        color: AppColors.border.withValues(
                          alpha: 0.30,
                        ),
                      ),

                      Expanded(
                        child: _Metric(
                          icon: Icons
                              .receipt_long_outlined,
                          label: 'STATUS',
                          value: 'Completed',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// METRIC
// =================================================================

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 13,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 6.2,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.55,
                  color: AppColors.textSecondary
                      .withValues(
                    alpha: 0.45,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}