import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

class SellerRecentOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  const SellerRecentOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  // =============================================================
  // HELPERS
  // =============================================================

  String _shortId(String id) {
    if (id.isEmpty) {
      return '--------';
    }

    if (id.length <= 8) {
      return id.toUpperCase();
    }

    return id.substring(0, 8).toUpperCase();
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';

      case 'accepted':
        return 'ACCEPTED';

      case 'preparing':
        return 'PREPARING';

      case 'out_for_delivery':
        return 'ON THE WAY';

      case 'ready_for_pickup':
        return 'READY';

      case 'completed':
        return 'COMPLETED';

      case 'cancelled':
        return 'CANCELLED';

      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
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

  DateTime? _createdAt() {
    final String? rawDate =
        order['created_at']?.toString();

    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }

    return DateTime.tryParse(rawDate)?.toLocal();
  }

  String _formattedDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    final DateTime now = DateTime.now();

    final bool isToday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    final DateTime yesterday =
        now.subtract(const Duration(days: 1));

    final bool isYesterday =
        date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    if (isToday) {
      return 'Today • ${DateFormat('h:mm a').format(date)}';
    }

    if (isYesterday) {
      return 'Yesterday • ${DateFormat('h:mm a').format(date)}';
    }

    if (date.year == now.year) {
      return DateFormat('MMM d • h:mm a').format(date);
    }

    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  bool _isNewOrder(
    String status,
    DateTime? createdAt,
  ) {
    if (status.toLowerCase() != 'pending' ||
        createdAt == null) {
      return false;
    }

    final Duration difference =
        DateTime.now().difference(createdAt);

    return !difference.isNegative &&
        difference.inMinutes <= 15;
  }

  String _orderTypeLabel(String orderType) {
    switch (orderType.toLowerCase()) {
      case 'delivery':
        return 'Delivery';

      case 'pickup':
        return 'Pickup';

      default:
        return orderType
            .replaceAll('_', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map(
              (word) =>
                  '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
            )
            .join(' ');
    }
  }

  IconData _orderTypeIcon(String orderType) {
    return orderType.toLowerCase() == 'delivery'
        ? Icons.delivery_dining_outlined
        : Icons.storefront_outlined;
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final String id =
        (order['id'] ?? '').toString();

    final String status =
        (order['status'] ?? 'pending')
            .toString()
            .toLowerCase();

    final String orderType =
        (order['order_type'] ?? 'delivery')
            .toString()
            .toLowerCase();

    final double total =
        (order['total_price'] as num?)
                ?.toDouble() ??
            0.0;

    final DateTime? createdAt =
        _createdAt();

    final Color statusColor =
        _statusColor(status);

    final bool isNew =
        _isNewOrder(status, createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.38,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // =================================================
              // TOP
              // =================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // ORDER TYPE ICON
                  // =============================================

                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(13),
                      border: Border.all(
                        color: AppColors.border
                            .withValues(alpha: 0.24),
                      ),
                    ),
                    child: Icon(
                      _orderTypeIcon(orderType),
                      size: 19,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =============================================
                  // ORDER ID + DATE
                  // =============================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Order #${_shortId(id)}',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.1,
                                  fontWeight:
                                      FontWeight.w900,
                                  letterSpacing: -0.25,
                                  color:
                                      AppColors.textPrimary,
                                ),
                              ),
                            ),

                            if (isNew) ...[
                              const SizedBox(width: 7),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.textPrimary,
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    fontSize: 6.5,
                                    height: 1,
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 12,
                              color: AppColors
                                  .textSecondary
                                  .withValues(alpha: 0.60),
                            ),

                            const SizedBox(width: 5),

                            Flexible(
                              child: Text(
                                _formattedDate(
                                  createdAt,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  height: 1,
                                  fontWeight:
                                      FontWeight.w500,
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                        alpha: 0.68,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // =============================================
                  // STATUS
                  // =============================================

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                          BorderRadius.circular(30),
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
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          _statusLabel(status),
                          style: TextStyle(
                            fontSize: 7.5,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.35,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border.withValues(
                  alpha: 0.22,
                ),
              ),

              const SizedBox(height: 13),

              // =================================================
              // BOTTOM
              // =================================================

              Row(
                children: [
                  // =============================================
                  // FULFILLMENT
                  // =============================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FULFILLMENT',
                          style: TextStyle(
                            fontSize: 7,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.85,
                            color: AppColors
                                .textSecondary
                                .withValues(alpha: 0.48),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(
                              _orderTypeIcon(orderType),
                              size: 14,
                              color:
                                  AppColors.textPrimary,
                            ),

                            const SizedBox(width: 6),

                            Flexible(
                              child: Text(
                                _orderTypeLabel(
                                  orderType,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // =============================================
                  // TOTAL
                  // =============================================

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 7,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.85,
                          color: AppColors.textSecondary
                              .withValues(alpha: 0.48),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '₱${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // =============================================
                  // OPEN ORDER
                  // =============================================

                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius:
                          BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}