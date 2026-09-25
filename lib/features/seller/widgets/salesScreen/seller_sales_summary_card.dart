import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesSummaryCard
    extends StatelessWidget {
  final String eyebrow;
  final String value;
  final String subtitle;
  final IconData icon;

  const SellerSalesSummaryCard({
    super.key,
    required this.eyebrow,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.34,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(21),
        child: Stack(
          children: [
            // ===================================================
            // SUBTLE DECORATION
            // ===================================================

            Positioned(
              top: -35,
              right: -30,
              child: Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textPrimary
                      .withValues(
                    alpha: 0.018,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 20,
              right: -25,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors
                        .textPrimary
                        .withValues(
                      alpha: 0.025,
                    ),
                  ),
                ),
              ),
            ),

            // ===================================================
            // CONTENT
            // ===================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                14,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // TOP
                  // =============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 39,
                        height: 39,
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .textPrimary,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 10,
                              offset:
                                  const Offset(
                                0,
                                4,
                              ),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          eyebrow,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontSize: 7.5,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing:
                                0.75,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.62,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // =============================================
                  // REVENUE LABEL
                  // =============================================

                  Text(
                    'REVENUE',
                    style: TextStyle(
                      fontSize: 7,
                      height: 1,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 0.9,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // =============================================
                  // VALUE
                  // =============================================

                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style:
                            const TextStyle(
                          fontSize: 22,
                          height: 1,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: -0.7,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // =============================================
                  // DIVIDER
                  // =============================================

                  Container(
                    height: 1,
                    color: AppColors.border
                        .withValues(
                      alpha: 0.30,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =============================================
                  // ORDERS FOOTER
                  // =============================================

                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .background,
                          borderRadius:
                              BorderRadius.circular(
                            9,
                          ),
                          border: Border.all(
                            color: AppColors
                                .border
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons
                              .receipt_long_outlined,
                          size: 13,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'ORDERS',
                              style: TextStyle(
                                fontSize: 6.5,
                                height: 1,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    0.65,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.42,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                height: 1,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),
                          ],
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