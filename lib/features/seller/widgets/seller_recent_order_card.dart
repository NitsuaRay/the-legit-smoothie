import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SellerRecentOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const SellerRecentOrderCard({
    super.key,
    required this.order,
  });

  String _shortId(String id) {
    if (id.length <= 8) return id.toUpperCase();

    return id.substring(0, 8).toUpperCase();
  }

  String _statusLabel(String status) {
    return status
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;

      case 'accepted':
        return Colors.orange.shade800;

      case 'preparing':
        return AppColors.primary;

      case 'out_for_delivery':
      case 'ready_for_pickup':
        return Colors.blue.shade600;

      case 'completed':
        return AppColors.success;

      case 'cancelled':
        return AppColors.error;

      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String id =
        (order['id'] ?? '').toString();

    final String status =
        (order['status'] ?? 'pending').toString();

    final String orderType =
        (order['order_type'] ?? 'delivery').toString();

    final double total =
        (order['total_price'] as num?)
                ?.toDouble() ??
            0;

    final Color statusColor =
        _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              orderType == 'delivery'
                  ? Icons.delivery_dining_rounded
                  : Icons.storefront_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${_shortId(id)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '₱${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}