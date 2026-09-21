import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import 'checkout_card.dart';
import 'checkout_divider.dart';
import 'checkout_summary_row.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final int totalItemCount;
  final String orderType;

  final double subtotal;
  final double deliveryFee;
  final double grandTotal;

  const CheckoutOrderSummary({
    super.key,
    required this.totalItemCount,
    required this.orderType,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDelivery = orderType == 'delivery';

    return CheckoutCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          CheckoutSummaryRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Subtotal',
            subtitle:
                '$totalItemCount ${totalItemCount == 1 ? 'item' : 'items'} in your cart',
            value: AppHelpers.formatCurrency(subtotal),
          ),

          const CheckoutDivider(),

          CheckoutSummaryRow(
            icon: isDelivery
                ? Icons.local_shipping_outlined
                : Icons.storefront_outlined,
            label: isDelivery
                ? 'Delivery Fee'
                : 'Store Pickup',
            subtitle: isDelivery
                ? 'Standard local delivery'
                : 'Collect your order from the store',
            value: isDelivery
                ? AppHelpers.formatCurrency(deliveryFee)
                : 'FREE',
            valueColor: isDelivery
                ? AppColors.textPrimary
                : AppColors.success,
          ),

          const CheckoutDivider(
            verticalPadding: 17,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Final amount for this order',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Text(
                AppHelpers.formatCurrency(grandTotal),
                style: const TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}