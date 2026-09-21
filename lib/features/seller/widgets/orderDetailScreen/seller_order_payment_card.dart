import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class SellerOrderPaymentCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;
  final bool isDelivery;

  const SellerOrderPaymentCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.isDelivery,
  });

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
          // BREAKDOWN
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
                // SUBTOTAL
                // =================================================

                _PriceRow(
                  icon: Icons.receipt_long_outlined,
                  label: 'Subtotal',
                  subtitle: 'Items total',
                  amount: subtotal,
                ),

                const SizedBox(height: 15),

                // =================================================
                // DELIVERY / PICKUP
                // =================================================

                if (isDelivery)
                  _PriceRow(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Delivery Fee',
                    subtitle: 'Delivery charge',
                    amount: deliveryFee,
                  )
                else
                  const _PickupRow(),
              ],
            ),
          ),

          // =====================================================
          // TOTAL
          // =====================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              16,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(21),
                bottomRight: Radius.circular(21),
              ),
              border: Border(
                top: BorderSide(
                  color: AppColors.border.withValues(
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
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        isDelivery
                            ? 'Amount to collect'
                            : 'Pickup amount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary
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
                  AppHelpers.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
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

// ===================================================================
// PRICE ROW
// ===================================================================

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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(
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
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary
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
          AppHelpers.formatCurrency(amount),
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

// ===================================================================
// PICKUP ROW
// ===================================================================

class _PickupRow extends StatelessWidget {
  const _PickupRow();

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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.25,
              ),
            ),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 12),

        // =========================================================
        // PICKUP INFO
        // =========================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Pickup',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'No delivery fee',
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary
                      .withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),

        // =========================================================
        // FREE BADGE
        // =========================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.30,
              ),
            ),
          ),
          child: const Text(
            'FREE',
            style: TextStyle(
              fontSize: 8.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.45,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}