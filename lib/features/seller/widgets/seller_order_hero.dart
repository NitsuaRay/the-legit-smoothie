import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import 'seller_order_status.dart';

class SellerOrderHero extends StatelessWidget {
  final String orderId;
  final String status;
  final String orderType;
  final DateTime? createdAt;
  final int totalQuantity;
  final double total;
  final bool isDelivery;

  const SellerOrderHero({
    super.key,
    required this.orderId,
    required this.status,
    required this.orderType,
    required this.createdAt,
    required this.totalQuantity,
    required this.total,
    required this.isDelivery,
  });

  String get _shortOrderId {
    final shortId =
        orderId.length >= 6 ? orderId.substring(0, 6) : orderId;

    return '#${shortId.toUpperCase()}';
  }

  String get _formattedOrderType {
    switch (orderType) {
      case 'delivery':
        return 'Delivery';
      case 'pickup':
        return 'Pickup';
      default:
        return formatSellerOrderStatus(orderType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = sellerOrderStatusConfig(status);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  config.icon,
                  size: 22,
                  color: config.color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shortOrderId,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM d, yyyy • h:mm a',
                        ).format(createdAt!),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _StatusBadge(status: status),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.30),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _MiniInfo(
                icon: isDelivery
                    ? Icons.delivery_dining_outlined
                    : Icons.storefront_outlined,
                label: 'Order Type',
                value: _formattedOrderType,
              ),

              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: AppColors.border.withValues(alpha: 0.35),
              ),

              _MiniInfo(
                icon: Icons.shopping_bag_outlined,
                label: 'Items',
                value: '$totalQuantity',
              ),

              const Spacer(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
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
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 6.8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final config = sellerOrderStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: config.color.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        config.label.toUpperCase(),
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.35,
          color: config.color,
        ),
      ),
    );
  }
}