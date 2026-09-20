import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class OrderTrackingHeader extends StatelessWidget {
  final String orderId;
  final String status;
  final String orderType;
  final double totalPrice;
  final String? address;
  final String? notes;
  final DateTime? createdAt;

  const OrderTrackingHeader({
    super.key,
    required this.orderId,
    required this.status,
    required this.orderType,
    required this.totalPrice,
    required this.address,
    required this.notes,
    required this.createdAt,
  });

  // ============================================================
  // STATUS CONFIGURATION
  // ============================================================
  Map<String, dynamic> _getStatusStyle() {
    switch (status.toLowerCase()) {
      case 'accepted':
        return {
          'label': 'Accepted',
          'icon': Icons.check_circle_rounded,
          'color': AppColors.primary,
          'background': AppColors.primary.withValues(
            alpha: 0.10,
          ),
        };

      case 'preparing':
        return {
          'label': 'Preparing',
          'icon': Icons.restaurant_rounded,
          'color': AppColors.secondaryDark,
          'background': AppColors.secondaryDark.withValues(
            alpha: 0.10,
          ),
        };

      case 'out_for_delivery':
        return {
          'label': 'Out for Delivery',
          'icon': Icons.delivery_dining_rounded,
          'color': AppColors.primary,
          'background': AppColors.primary.withValues(
            alpha: 0.10,
          ),
        };

      case 'ready_for_pickup':
        return {
          'label': 'Ready for Pickup',
          'icon': Icons.storefront_rounded,
          'color': AppColors.primary,
          'background': AppColors.primary.withValues(
            alpha: 0.10,
          ),
        };

      case 'completed':
        return {
          'label': 'Completed',
          'icon': Icons.check_circle_rounded,
          'color': AppColors.success,
          'background': AppColors.success.withValues(
            alpha: 0.10,
          ),
        };

      case 'cancelled':
        return {
          'label': 'Cancelled',
          'icon': Icons.cancel_rounded,
          'color': AppColors.error,
          'background': AppColors.error.withValues(
            alpha: 0.10,
          ),
        };

      case 'pending':
      default:
        return {
          'label': 'Pending',
          'icon': Icons.schedule_rounded,
          'color': AppColors.secondaryDark,
          'background': AppColors.secondaryDark.withValues(
            alpha: 0.10,
          ),
        };
    }
  }

  String _formatOrderType() {
    switch (orderType.toLowerCase()) {
      case 'pickup':
        return 'STORE PICKUP';

      case 'delivery':
      default:
        return 'DELIVERY';
    }
  }

  IconData _getOrderTypeIcon() {
    switch (orderType.toLowerCase()) {
      case 'pickup':
        return Icons.storefront_rounded;

      case 'delivery':
      default:
        return Icons.local_shipping_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle();

    final Color statusColor = statusStyle['color'];
    final Color statusBackground = statusStyle['background'];
    final String statusLabel = statusStyle['label'];

    final bool hasAddress =
        orderType.toLowerCase() == 'delivery' &&
        address != null &&
        address!.trim().isNotEmpty;

    final bool hasNotes =
        notes != null && notes!.trim().isNotEmpty;

    final String shortOrderId = orderId.length >= 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId.toUpperCase();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // TOP SECTION
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(
                            alpha: 0.14,
                          ),
                          AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primary,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Order ID + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'ORDER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color:
                                    AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.border,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatOrderType(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // Order ID with copy
                        GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text: orderId,
                              ),
                            );

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar();

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Order ID copied to clipboard.',
                                ),
                                duration:
                                    Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '#$shortOrderId',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                    color:
                                        AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          createdAt != null
                              ? AppHelpers.formatDate(
                                  createdAt!,
                                )
                              : 'Date unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ==================================================
                  // STATUS BADGE
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: statusColor.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // TOTAL AMOUNT HERO
            // ======================================================
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(
                      alpha: 0.07,
                    ),
                    AppColors.primary.withValues(
                      alpha: 0.025,
                    ),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Total icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Order total',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    AppHelpers.formatCurrency(totalPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ======================================================
            // ORDER INFORMATION
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                18,
              ),
              child: Column(
                children: [
                  // Order type
                  _InfoRow(
                    icon: _getOrderTypeIcon(),
                    title: 'Fulfillment',
                    value: _formatOrderType(),
                    valueColor: AppColors.textPrimary,
                  ),

                  // Address
                  if (hasAddress) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Address',
                      value: address!,
                      maxLines: 3,
                    ),
                  ],

                  // Notes
                  if (hasNotes) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'Order Note',
                      value: notes!,
                      maxLines: 4,
                      italic: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INFORMATION ROW
// ============================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final int maxLines;
  final Color? valueColor;
  final bool italic;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.maxLines = 2,
    this.valueColor,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    fontStyle: italic
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color:
                        valueColor ?? AppColors.textSecondary,
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