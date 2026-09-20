import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SellerOrderStatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const SellerOrderStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

SellerOrderStatusConfig sellerOrderStatusConfig(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const SellerOrderStatusConfig(
        label: 'Pending',
        color: Color(0xFFF59E0B),
        icon: Icons.schedule_rounded,
      );

    case 'accepted':
      return const SellerOrderStatusConfig(
        label: 'Accepted',
        color: Color(0xFF2563EB),
        icon: Icons.check_circle_outline_rounded,
      );

    case 'preparing':
      return const SellerOrderStatusConfig(
        label: 'Preparing',
        color: Color(0xFF7C3AED),
        icon: Icons.restaurant_outlined,
      );

    case 'out_for_delivery':
      return const SellerOrderStatusConfig(
        label: 'Out for Delivery',
        color: Color(0xFF0284C7),
        icon: Icons.delivery_dining_outlined,
      );

    case 'ready_for_pickup':
      return const SellerOrderStatusConfig(
        label: 'Ready for Pickup',
        color: Color(0xFF059669),
        icon: Icons.shopping_bag_outlined,
      );

    case 'completed':
      return const SellerOrderStatusConfig(
        label: 'Completed',
        color: AppColors.success,
        icon: Icons.task_alt_rounded,
      );

    case 'cancelled':
      return const SellerOrderStatusConfig(
        label: 'Cancelled',
        color: AppColors.error,
        icon: Icons.cancel_outlined,
      );

    default:
      return const SellerOrderStatusConfig(
        label: 'Order',
        color: AppColors.textSecondary,
        icon: Icons.receipt_long_outlined,
      );
  }
}

String formatSellerOrderStatus(String status) {
  return status
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}