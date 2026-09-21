import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/applied_promotion.dart';

class AppliedPromotionCard
    extends StatelessWidget {
  const AppliedPromotionCard({
    super.key,
    required this.promotion,
  });

  final AppliedPromotion promotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border
              .withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ICON
          // =====================================================

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  AppColors.textPrimary,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            alignment:
                Alignment.center,
            child: const Icon(
              Icons
                  .local_offer_outlined,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          // =====================================================
          // INFORMATION
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'BEST DEAL APPLIED',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.15,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  promotion.title,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 15,
                    height: 1.15,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.25,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                if (promotion
                        .isMixAndMatch &&
                    promotion
                            .applications >
                        0) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    promotion.applications ==
                            1
                        ? '1 bundle applied'
                        : '${promotion.applications} bundles applied',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w600,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 11,
                ),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .textPrimary
                            .withValues(
                          alpha: 0.06,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
                        ),
                      ),
                      child: Text(
                        'SAVE ${promotion.savingsLabel}',
                        style:
                            const TextStyle(
                          fontSize: 8,
                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing:
                              0.35,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons
                          .check_circle_outline_rounded,
                      size: 17,
                      color: AppColors
                          .textPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}