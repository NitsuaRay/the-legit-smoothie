import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';

import '../../promotions/models/applied_promotion.dart';

class CartOrderSummary extends StatelessWidget {
  final int totalCount;
  final double subtotal;
  final AppliedPromotion? promotion;
  final bool isCalculatingPromotion;
  final VoidCallback onCheckout;

  const CartOrderSummary({
    super.key,
    required this.totalCount,
    required this.subtotal,
    required this.onCheckout,
    this.promotion,
    this.isCalculatingPromotion = false,
  });

  // =============================================================
  // CALCULATED VALUES
  // =============================================================

  double get _discountAmount {
    return promotion?.discountAmount ?? 0;
  }

  bool get _hasPromotion {
    return promotion != null &&
        _discountAmount > 0;
  }

  double get _discountedSubtotal {
    final value =
        subtotal - _discountAmount;

    if (value < 0) {
      return 0;
    }

    return value;
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        16,
        AppConstants.defaultPadding,
        14 +
            MediaQuery.of(context)
                .padding
                .bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border
                .withValues(
              alpha: 0.28,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.04,
            ),
            blurRadius: 24,
            offset:
                const Offset(0, -7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            children: [
              Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.50,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '$totalCount '
                '${totalCount == 1 ? 'ITEM' : 'ITEMS'}',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.50,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // =====================================================
          // ORIGINAL SUBTOTAL
          // =====================================================

          _PriceRow(
            label: 'Subtotal',
            value:
                AppHelpers.formatCurrency(
              subtotal,
            ),
          ),

          // =====================================================
          // PROMOTION CALCULATION STATE
          // =====================================================

          if (isCalculatingPromotion) ...[
            const SizedBox(height: 13),

            const _PromotionLoading(),
          ],

          // =====================================================
          // APPLIED PROMOTION
          // =====================================================

          if (_hasPromotion &&
              !isCalculatingPromotion) ...[
            const SizedBox(height: 13),

            _PromotionSection(
              promotion: promotion!,
            ),

            const SizedBox(height: 13),

            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border
                  .withValues(
                alpha: 0.25,
              ),
            ),

            const SizedBox(height: 13),

            // ===================================================
            // SAVINGS
            // ===================================================

            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
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
                      10,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .savings_outlined,
                    size: 16,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                const Expanded(
                  child: Text(
                    'You save',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ),

                Text(
                  AppHelpers
                      .formatCurrency(
                    _discountAmount,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w900,
                    color: AppColors
                        .textPrimary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // =====================================================
          // ESTIMATED SUBTOTAL
          // =====================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(
              14,
            ),
            decoration: BoxDecoration(
              color: AppColors
                  .textPrimary,
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        _hasPromotion
                            ? 'Estimated subtotal'
                            : 'Subtotal',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        _hasPromotion
                            ? 'Promotion already applied'
                            : 'Before delivery fee',
                        style:
                            TextStyle(
                          fontSize: 7.5,
                          fontWeight:
                              FontWeight
                                  .w500,
                          color: Colors
                              .white
                              .withValues(
                            alpha: 0.58,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  AppHelpers
                      .formatCurrency(
                    _hasPromotion
                        ? _discountedSubtotal
                        : subtotal,
                  ),
                  style:
                      const TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.7,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          // =====================================================
          // DELIVERY NOTE
          // =====================================================

          Row(
            children: [
              Icon(
                Icons
                    .local_shipping_outlined,
                size: 13,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.55,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Delivery fee is calculated at checkout.',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.58,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // =====================================================
          // CHECKOUT BUTTON
          // =====================================================

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed:
                  isCalculatingPromotion
                      ? null
                      : onCheckout,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.textPrimary,
                disabledBackgroundColor:
                    AppColors.textPrimary
                        .withValues(
                  alpha: 0.50,
                ),
                foregroundColor:
                    Colors.white,
                disabledForegroundColor:
                    Colors.white
                        .withValues(
                  alpha: 0.70,
                ),
                elevation: 0,
                shadowColor:
                    Colors.transparent,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
              ),
              child:
                  isCalculatingPromotion
                      ? const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            SizedBox(
                              width: 15,
                              height: 15,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    1.8,
                                color: Colors
                                    .white,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Checking best deal...',
                              style:
                                  TextStyle(
                                fontSize:
                                    12,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              'Proceed to Checkout',
                              style:
                                  TextStyle(
                                fontSize:
                                    13,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    -0.1,
                              ),
                            ),
                            SizedBox(
                              width: 9,
                            ),
                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 17,
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// PRICE ROW
// =================================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PriceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
              color:
                  AppColors.textSecondary,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
            color:
                AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// PROMOTION
// =================================================================

class _PromotionSection
    extends StatelessWidget {
  final AppliedPromotion promotion;

  const _PromotionSection({
    required this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.textPrimary
            .withValues(
          alpha: 0.035,
        ),
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border
              .withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    BoxDecoration(
                  color: AppColors
                      .textPrimary,
                  borderRadius:
                      BorderRadius
                          .circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons
                      .local_offer_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'PROMOTION APPLIED',
                      style: TextStyle(
                        fontSize: 6.5,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            0.9,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      promotion.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight
                                .w900,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '-${AppHelpers.formatCurrency(promotion.discountAmount)}',
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ],
          ),

          if (promotion
                  .isMixAndMatch &&
              promotion.applications >
                  0) ...[
            const SizedBox(height: 9),

            Row(
              children: [
                const SizedBox(
                  width: 42,
                ),

                Icon(
                  Icons
                      .check_circle_outline_rounded,
                  size: 13,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.65,
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                Text(
                  promotion.applications ==
                          1
                      ? '1 bundle applied'
                      : '${promotion.applications} bundles applied',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w600,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// LOADING
// =================================================================

class _PromotionLoading
    extends StatelessWidget {
  const _PromotionLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary
            .withValues(
          alpha: 0.035,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 15,
            height: 15,
            child:
                CircularProgressIndicator(
              strokeWidth: 1.6,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Checking your cart for the best available deal...',
              style: TextStyle(
                fontSize: 8.5,
                fontWeight:
                    FontWeight.w600,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}