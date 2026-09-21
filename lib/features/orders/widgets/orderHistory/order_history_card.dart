import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import 'order_status_badge.dart';
import 'order_status_date.dart';

class OrderHistoryCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onUpdateNotes;
  final VoidCallback onOpenOrder;

  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.statusColor,
    required this.statusLabel,
    required this.onUpdateNotes,
    required this.onOpenOrder,
  });

  @override
  Widget build(BuildContext context) {
    final String orderId =
        order['id']?.toString() ?? '';

    final String status =
        (order['status'] ?? 'pending')
            .toString()
            .trim()
            .toLowerCase();

    final String orderType =
        (order['order_type'] ?? 'delivery')
            .toString()
            .trim()
            .toLowerCase();

    final String notes =
        (order['notes'] ?? '').toString().trim();

    final double totalPrice =
        (order['total_price'] as num?)
                ?.toDouble() ??
            0.0;

    final DateTime createdAt =
        DateTime.tryParse(
          order['created_at']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();

    final bool canUpdateNotes =
        status == 'pending' ||
        status == 'preparing';

    final bool isDelivery =
        orderType == 'delivery';

    final bool isNew =
        _isNewOrder(createdAt, status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenOrder,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.25,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              15,
              14,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ============================================
                // HEADER
                // ============================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    _OrderIcon(
                      status: status,
                      statusColor: statusColor,
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _shortOrderId(orderId),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 13.5,
                                    height: 1.05,
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: -0.35,
                                    color: AppColors
                                        .textPrimary,
                                  ),
                                ),
                              ),

                              if (isNew) ...[
                                const SizedBox(width: 7),

                                const _NewBadge(),
                              ],
                            ],
                          ),

                          const SizedBox(height: 6),

                          OrderStatusDate(
                            orderId: orderId,
                            currentStatus: status,
                            fallbackDate: createdAt,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    OrderStatusBadge(
                      label: statusLabel,
                      color: statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ============================================
                // FULFILLMENT
                // ============================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDelivery
                              ? Icons
                                  .delivery_dining_outlined
                              : Icons
                                  .storefront_outlined,
                          size: 16,
                          color:
                              AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FULFILLMENT',
                              style: TextStyle(
                                fontSize: 6.3,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 0.9,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.48,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              isDelivery
                                  ? 'Delivery order'
                                  : 'Store pickup',
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: -0.15,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.24,
                            ),
                          ),
                        ),
                        child: Text(
                          isDelivery
                              ? 'DELIVERY'
                              : 'PICKUP',
                          style: TextStyle(
                            fontSize: 6.3,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.55,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================
                // NOTES
                // ============================================

                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background
                          .withValues(alpha: 0.60),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .sticky_note_2_outlined,
                          size: 13,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.65,
                          ),
                        ),

                        const SizedBox(width: 7),

                        Expanded(
                          child: Text(
                            notes,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              height: 1.3,
                              fontWeight:
                                  FontWeight.w500,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.78,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border.withValues(
                    alpha: 0.20,
                  ),
                ),

                const SizedBox(height: 13),

                // ============================================
                // FOOTER
                // ============================================

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER TOTAL',
                            style: TextStyle(
                              fontSize: 6.2,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.85,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            AppHelpers.formatCurrency(
                              totalPrice,
                            ),
                            style: const TextStyle(
                              fontSize: 15.5,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -0.45,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (canUpdateNotes) ...[
                      _ActionButton(
                        tooltip:
                            'Update instructions',
                        icon:
                            Icons.edit_note_outlined,
                        onTap: onUpdateNotes,
                      ),

                      const SizedBox(width: 8),
                    ],

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onOpenOrder,
                        borderRadius:
                            BorderRadius.circular(11),
                        child: Ink(
                          height: 36,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.textPrimary,
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                status == 'cancelled'
                                    ? Icons
                                        .receipt_long_outlined
                                    : Icons
                                        .near_me_outlined,
                                size: 14,
                                color: Colors.white,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                status == 'cancelled'
                                    ? 'Details'
                                    : 'Track',
                                style:
                                    const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight:
                                      FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(width: 4),

                              const Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _shortOrderId(String orderId) {
    if (orderId.isEmpty) {
      return 'Order';
    }

    final String shortId =
        orderId.length >= 8
            ? orderId.substring(0, 8)
            : orderId;

    return 'Order #${shortId.toUpperCase()}';
  }

  bool _isNewOrder(
    DateTime createdAt,
    String status,
  ) {
    if (status != 'pending') {
      return false;
    }

    final Duration age =
        DateTime.now().difference(createdAt);

    return !age.isNegative &&
        age.inMinutes <= 15;
  }
}

// ================================================================
// ORDER STATUS ICON
// ================================================================

class _OrderIcon extends StatelessWidget {
  final String status;
  final Color statusColor;

  const _OrderIcon({
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: statusColor.withValues(
              alpha: 0.08,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _statusIcon(status),
            size: 13,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;

      case 'accepted':
        return Icons.check_rounded;

      case 'preparing':
        return Icons.restaurant_rounded;

      case 'out_for_delivery':
        return Icons.delivery_dining_rounded;

      case 'ready_for_pickup':
        return Icons.shopping_bag_rounded;

      case 'completed':
        return Icons.done_all_rounded;

      case 'cancelled':
        return Icons.close_rounded;

      default:
        return Icons.receipt_long_rounded;
    }
  }
}

// ================================================================
// NEW BADGE
// ================================================================

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          fontSize: 5.8,
          height: 1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ================================================================
// SMALL ACTION BUTTON
// ================================================================

class _ActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Ink(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.28,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}