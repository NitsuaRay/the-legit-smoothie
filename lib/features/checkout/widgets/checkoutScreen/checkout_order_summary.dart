import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

import '../../../promotions/models/applied_promotion.dart';

import 'checkout_card.dart';
import 'checkout_divider.dart';
import 'checkout_summary_row.dart';

class CheckoutOrderSummary
    extends StatelessWidget {
  final int totalItemCount;
  final String orderType;

  final double subtotal;
  final double deliveryFee;
  final double grandTotal;

  final AppliedPromotion? promotion;
  final bool isCalculatingPromotion;

  const CheckoutOrderSummary({
    super.key,
    required this.totalItemCount,
    required this.orderType,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    this.promotion,
    this.isCalculatingPromotion = false,
  });

  double get _discountAmount {
    return promotion?.discountAmount ?? 0;
  }

  bool get _hasPromotion {
    return promotion != null &&
        _discountAmount > 0;
  }

  double get _discountedSubtotal {
    return (subtotal - _discountAmount)
        .clamp(
          0.0,
          double.infinity,
        )
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivery =
        orderType == 'delivery';

    return CheckoutCard(
      padding:
          const EdgeInsets.all(18),
      child: Column(
        children: [
          // =====================================================
          // SUBTOTAL
          // =====================================================

          CheckoutSummaryRow(
            icon:
                Icons.shopping_bag_outlined,
            label: 'Subtotal',
            subtitle:
                '$totalItemCount '
                '${totalItemCount == 1 ? 'item' : 'items'} in your cart',
            value:
                AppHelpers.formatCurrency(
              subtotal,
            ),
          ),

          // =====================================================
          // PROMOTION LOADING
          // =====================================================

          if (isCalculatingPromotion) ...[
            const CheckoutDivider(),

            const _PromotionLoadingRow(),
          ],

          // =====================================================
          // PROMOTION
          // =====================================================

          if (_hasPromotion &&
              !isCalculatingPromotion) ...[
            const CheckoutDivider(),

            _PromotionRow(
              promotion: promotion!,
            ),

            const CheckoutDivider(),

            CheckoutSummaryRow(
              icon:
                  Icons.savings_outlined,
              label:
                  'Discounted Subtotal',
              subtitle:
                  'Your promotion has been applied',
              value:
                  AppHelpers.formatCurrency(
                _discountedSubtotal,
              ),
            ),
          ],

          // =====================================================
          // DELIVERY
          // =====================================================

          const CheckoutDivider(),

          CheckoutSummaryRow(
            icon: isDelivery
                ? Icons
                    .local_shipping_outlined
                : Icons
                    .storefront_outlined,
            label: isDelivery
                ? 'Delivery Fee'
                : 'Store Pickup',
            subtitle: isDelivery
                ? 'Standard local delivery'
                : 'Collect your order from the store',
            value: isDelivery
                ? AppHelpers.formatCurrency(
                    deliveryFee,
                  )
                : 'FREE',
            valueColor: isDelivery
                ? AppColors.textPrimary
                : AppColors.success,
          ),

          const CheckoutDivider(
            verticalPadding: 17,
          ),

          // =====================================================
          // TOTAL
          // =====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            -0.3,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      _hasPromotion
                          ? 'Promotion savings included'
                          : 'Final amount for this order',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight:
                            FontWeight.w500,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Text(
                AppHelpers.formatCurrency(
                  grandTotal,
                ),
                style:
                    const TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.9,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ],
          ),

          // =====================================================
          // SAVINGS FOOTER
          // =====================================================

          if (_hasPromotion &&
              !isCalculatingPromotion) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors
                    .textPrimary
                    .withValues(
                  alpha: 0.045,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .check_circle_outline_rounded,
                    size: 15,
                    color: AppColors
                        .textPrimary,
                  ),

                  const SizedBox(width: 8),

                  const Expanded(
                    child: Text(
                      'Total promotion savings',
                      style: TextStyle(
                        fontSize: 9,
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
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w900,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =================================================================
// PROMOTION ROW
// =================================================================

class _PromotionRow
    extends StatelessWidget {
  final AppliedPromotion promotion;

  const _PromotionRow({
    required this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: const Icon(
            Icons.local_offer_outlined,
            size: 17,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Promotion',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w800,
                  color: AppColors
                      .textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                promotion.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
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

              if (promotion
                      .isMixAndMatch &&
                  promotion.applications >
                      0) ...[
                const SizedBox(height: 2),

                Text(
                  promotion.applications ==
                          1
                      ? '1 bundle applied'
                      : '${promotion.applications} bundles applied',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 10),

        Text(
          '-${AppHelpers.formatCurrency(promotion.discountAmount)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w900,
            color:
                AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// LOADING
// =================================================================

class _PromotionLoadingRow
    extends StatelessWidget {
  const _PromotionLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 17,
          height: 17,
          child:
              CircularProgressIndicator(
            strokeWidth: 1.7,
            color:
                AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Text(
            'Checking the best available deal...',
            style: TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ),
      ],
    );
  }
}