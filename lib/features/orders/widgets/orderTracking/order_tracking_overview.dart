import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class OrderTrackingOverview extends StatelessWidget {
  final String orderId;
  final String status;
  final String orderType;
  final double totalPrice;
  final String? address;
  final String? notes;
  final DateTime? createdAt;

  const OrderTrackingOverview({
    super.key,
    required this.orderId,
    required this.status,
    required this.orderType,
    required this.totalPrice,
    required this.address,
    required this.notes,
    required this.createdAt,
  });

  bool get _isDelivery =>
      orderType.toLowerCase() == 'delivery';

  String get _shortOrderId {
    if (orderId.isEmpty) {
      return 'ORDER';
    }

    return orderId.length >= 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();
  }

  String get _fulfillmentLabel =>
      _isDelivery ? 'Delivery' : 'Store pickup';

  Map<String, dynamic> get _statusConfig {
    switch (status.toLowerCase()) {
      case 'accepted':
        return {
          'label': 'Accepted',
          'color': AppColors.primary,
        };

      case 'preparing':
        return {
          'label': 'Preparing',
          'color': AppColors.secondaryDark,
        };

      case 'out_for_delivery':
        return {
          'label': 'Out for delivery',
          'color': AppColors.primary,
        };

      case 'ready_for_pickup':
        return {
          'label': 'Ready for pickup',
          'color': AppColors.primary,
        };

      case 'completed':
        return {
          'label': 'Completed',
          'color': AppColors.success,
        };

      case 'cancelled':
        return {
          'label': 'Cancelled',
          'color': AppColors.error,
        };

      default:
        return {
          'label': 'Pending',
          'color': AppColors.secondaryDark,
        };
    }
  }

  Future<void> _copyOrderId(
    BuildContext context,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: orderId),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Text(
            'Order ID copied.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig;
    final Color statusColor =
        config['color'] as Color;

    final String statusLabel =
        config['label'] as String;

    final bool hasAddress =
        _isDelivery &&
        address != null &&
        address!.trim().isNotEmpty;

    final bool hasNotes =
        notes != null &&
        notes!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER ID',
                      style: TextStyle(
                        fontSize: 6.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.48),
                      ),
                    ),

                    const SizedBox(height: 5),

                    GestureDetector(
                      onTap: () =>
                          _copyOrderId(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '#$_shortOrderId',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -0.3,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          Icon(
                            Icons.copy_outlined,
                            size: 12,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppHelpers.formatDate(
                          createdAt!,
                        ),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.66,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: 0.07,
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                  border: Border.all(
                    color: statusColor.withValues(
                      alpha: 0.14,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        fontSize: 6.5,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.45,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    size: 17,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER TOTAL',
                        style: TextStyle(
                          fontSize: 6.3,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                          color: Colors.white.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fulfillmentLabel,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  AppHelpers.formatCurrency(
                    totalPrice,
                  ),
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
          ),

          const SizedBox(height: 13),

          _InfoRow(
            icon: _isDelivery
                ? Icons.delivery_dining_outlined
                : Icons.storefront_outlined,
            label: 'FULFILLMENT',
            value: _fulfillmentLabel,
          ),

          if (hasAddress) ...[
            const SizedBox(height: 9),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'DELIVERY ADDRESS',
              value: address!,
              maxLines: 4,
            ),
          ],

          if (hasNotes) ...[
            const SizedBox(height: 9),
            _InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'ORDER NOTE',
              value: notes!,
              maxLines: 4,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int maxLines;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: 15,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.46),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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