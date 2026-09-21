import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import 'receipt_card.dart';

class ReceiptPaymentCard extends StatelessWidget {
  final int itemCount;
  final bool isDelivery;
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;

  const ReceiptPaymentCard({
    super.key,
    required this.itemCount,
    required this.isDelivery,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptCard(
      child: Column(
        children: [
          _PaymentRow(
            label: 'Subtotal',
            subtitle: '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            value: AppHelpers.formatCurrency(subtotal),
          ),
          const ReceiptDivider(),
          _PaymentRow(
            label: isDelivery ? 'Delivery fee' : 'Store pickup',
            subtitle: isDelivery
                ? 'Standard local delivery'
                : 'No delivery charge',
            value: isDelivery
                ? AppHelpers.formatCurrency(deliveryFee)
                : 'FREE',
            valueColor:
                isDelivery ? null : AppColors.success,
          ),
          const ReceiptDivider(verticalPadding: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Amount for this order',
                      style: TextStyle(
                        fontSize: 8.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppHelpers.formatCurrency(grandTotal),
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
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

class _PaymentRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final Color? valueColor;

  const _PaymentRow({
    required this.label,
    required this.subtitle,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}