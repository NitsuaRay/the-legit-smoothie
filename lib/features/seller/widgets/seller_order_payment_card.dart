import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class SellerOrderPaymentCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double total;

  const SellerOrderPaymentCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.40,
          ),
        ),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Subtotal',
            amount: subtotal,
          ),

          const SizedBox(height: 11),

          _PriceRow(
            label: 'Delivery Fee',
            amount: deliveryFee,
          ),

          const SizedBox(height: 13),

          Divider(
            height: 1,
            color: AppColors.border.withValues(
              alpha: 0.35,
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Text(
                AppHelpers.formatCurrency(total),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
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

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;

  const _PriceRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        Text(
          AppHelpers.formatCurrency(amount),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}