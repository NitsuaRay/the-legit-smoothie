import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class CheckoutOverview extends StatelessWidget {
  final int totalItemCount;
  final String orderType;
  final double deliveryFee;
  final double grandTotal;

  const CheckoutOverview({
    super.key,
    required this.totalItemCount,
    required this.orderType,
    required this.deliveryFee,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDelivery = orderType == 'delivery';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isDelivery
                  ? Icons.local_shipping_outlined
                  : Icons.storefront_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalItemCount '
                  '${totalItemCount == 1 ? 'item' : 'items'} in your order',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  isDelivery
                      ? 'Delivery • ${AppHelpers.formatCurrency(deliveryFee)} fee'
                      : 'Store Pickup • No delivery fee',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white.withValues(alpha: 0.48),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                AppHelpers.formatCurrency(grandTotal),
                style: const TextStyle(
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}