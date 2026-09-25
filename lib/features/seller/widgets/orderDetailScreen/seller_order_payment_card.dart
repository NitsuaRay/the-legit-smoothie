import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class SellerOrderPaymentCard extends StatelessWidget {
  final double originalSubtotal;
  final double discountAmount;
  final String? promotionTitle;

  final double subtotal;
  final double deliveryFee;
  final double total;
  final bool isDelivery;

  const SellerOrderPaymentCard({
    super.key,
    required this.originalSubtotal,
    required this.discountAmount,
    this.promotionTitle,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.isDelivery,
  });

  bool get _hasPromotion {
    return discountAmount > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.38,
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
      child: Column(
        children: [
          // =====================================================
          // FULL ORDER BREAKDOWN
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              17,
              16,
              16,
            ),
            child: Column(
              children: [
                // =================================================
                // ORIGINAL ITEMS SUBTOTAL
                // =================================================

                _PriceRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Items Subtotal',
                  subtitle: 'Original items total',
                  amount: originalSubtotal,
                ),

                // =================================================
                // PROMOTION DISCOUNT
                // =================================================

                if (_hasPromotion) ...[
                  const SizedBox(height: 15),

                  _DiscountRow(
                    promotionTitle:
                        promotionTitle
                                    ?.trim()
                                    .isNotEmpty ==
                                true
                            ? promotionTitle!
                            : 'Promotion Discount',
                    discountAmount:
                        discountAmount,
                  ),

                  const SizedBox(height: 15),

                  // ===============================================
                  // SUBTOTAL AFTER DISCOUNT
                  // ===============================================

                  _PriceRow(
                    icon: Icons.savings_outlined,
                    label: 'Discounted Subtotal',
                    subtitle:
                        'Items total after promotion',
                    amount: subtotal,
                  ),
                ],

                // =================================================
                // DELIVERY FEE
                // =================================================

                if (isDelivery) ...[
                  const SizedBox(height: 15),

                  _PriceRow(
                    icon:
                        Icons.delivery_dining_rounded,
                    label: 'Delivery Fee',
                    subtitle: deliveryFee > 0
                        ? 'Delivery charge'
                        : 'Free delivery',
                    amount: deliveryFee,
                  ),
                ],
              ],
            ),
          ),

          // =====================================================
          // CALCULATION DIVIDER
          // =====================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border.withValues(
                alpha: 0.30,
              ),
            ),
          ),

          // =====================================================
          // CALCULATION SUMMARY
          // =====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              15,
            ),
            child: Column(
              children: [
                _CompactAmountRow(
                  label: 'Subtotal',
                  amount: originalSubtotal,
                ),

                if (_hasPromotion) ...[
                  const SizedBox(height: 9),

                  _CompactAmountRow(
                    label: 'Promotion',
                    amount: -discountAmount,
                    isDiscount: true,
                  ),
                ],

                if (isDelivery) ...[
                  const SizedBox(height: 9),

                  _CompactAmountRow(
                    label: 'Delivery Fee',
                    amount: deliveryFee,
                  ),
                ],
              ],
            ),
          ),

          // =====================================================
          // FINAL TOTAL
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              17,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  const BorderRadius.only(
                bottomLeft:
                    Radius.circular(21),
                bottomRight:
                    Radius.circular(21),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.30,
                  ),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                // =================================================
                // TOTAL LABEL
                // =================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER TOTAL',
                        style: TextStyle(
                          fontSize: 8,
                          height: 1,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 0.9,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        isDelivery
                            ? 'Final amount including delivery'
                            : 'Final pickup amount',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w600,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // =================================================
                // TOTAL AMOUNT
                // =================================================

                Text(
                  AppHelpers.formatCurrency(
                    total,
                  ),
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.5,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// PROMOTION DISCOUNT ROW
// =================================================================

class _DiscountRow extends StatelessWidget {
  final String promotionTitle;
  final double discountAmount;

  const _DiscountRow({
    required this.promotionTitle,
    required this.discountAmount,
  });

  @override
  Widget build(BuildContext context) {
    final String displayTitle =
        promotionTitle.trim().isNotEmpty
            ? promotionTitle.trim()
            : 'Promotion Discount';

    return Row(
      children: [
        // =========================================================
        // PROMOTION ICON
        // =========================================================

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_offer_outlined,
            size: 17,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // PROMOTION TITLE
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                displayTitle,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.15,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Promotion applied',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w500,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // DISCOUNT AMOUNT
        // =========================================================

        Text(
          '-${AppHelpers.formatCurrency(discountAmount)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// MAIN PRICE ROW
// =================================================================

class _PriceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final double amount;

  const _PriceRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // =========================================================
        // ICON
        // =========================================================

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // LABEL
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight:
                      FontWeight.w500,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // AMOUNT
        // =========================================================

        Text(
          AppHelpers.formatCurrency(
            amount,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// COMPACT CALCULATION ROW
// =================================================================

class _CompactAmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDiscount;

  const _CompactAmountRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final double displayAmount =
        amount.abs();

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.75,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Text(
          isDiscount
              ? '-${AppHelpers.formatCurrency(displayAmount)}'
              : AppHelpers.formatCurrency(
                  displayAmount,
                ),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isDiscount
                ? AppColors.success
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}