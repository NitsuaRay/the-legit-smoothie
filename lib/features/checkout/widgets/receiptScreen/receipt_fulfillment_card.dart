import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'receipt_card.dart';

class ReceiptFulfillmentCard extends StatelessWidget {
  final bool isDelivery;
  final String contactNumber;
  final String? deliveryAddress;

  const ReceiptFulfillmentCard({
    super.key,
    required this.isDelivery,
    required this.contactNumber,
    this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptCard(
      child: Column(
        children: [
          _DetailRow(
            icon: isDelivery
                ? Icons.delivery_dining_outlined
                : Icons.storefront_outlined,
            label: 'ORDER TYPE',
            value: isDelivery ? 'Delivery' : 'Store Pickup',
          ),
          const ReceiptDivider(),
          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'CONTACT NUMBER',
            value: contactNumber.trim().isEmpty
                ? 'Not provided'
                : contactNumber,
          ),
          if (isDelivery &&
              deliveryAddress != null &&
              deliveryAddress!.trim().isNotEmpty) ...[
            const ReceiptDivider(),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'DELIVERY ADDRESS',
              value: deliveryAddress!,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.85,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}