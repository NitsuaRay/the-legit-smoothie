import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class SellerOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onTap;

  const SellerOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String status =
        order['status']?.toString() ?? 'pending';

    final String orderType =
        order['order_type']?.toString() ?? '';

    final String customerName = _customerName();
    final int itemCount = _itemCount();
    final double total = _orderTotal();

    final DateTime? createdAt = DateTime.tryParse(
      order['created_at']?.toString() ?? '',
    )?.toLocal();

    final _OrderStatusConfig config =
        _statusConfig(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.black.withValues(
                alpha: 0.055,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.035,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              17,
              16,
              15,
              15,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =================================================
                // TOP ROW
                // =================================================
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    // =============================================
                    // ORDER ICON
                    // =============================================
                    _OrderIcon(
                      config: config,
                    ),

                    const SizedBox(width: 12),

                    // =============================================
                    // ORDER NUMBER + DATE
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
                                  _shortOrderId(),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(
                                    fontSize: 14,
                                    height: 1,
                                    fontWeight:
                                        FontWeight.w900,
                                    letterSpacing: -0.4,
                                    color: AppColors
                                        .textPrimary,
                                  ),
                                ),
                              ),

                              if (_isNewOrder(
                                createdAt,
                                status,
                              )) ...[
                                const SizedBox(
                                  width: 7,
                                ),
                                const _NewBadge(),
                              ],
                            ],
                          ),

                          if (createdAt != null) ...[
                            const SizedBox(height: 5),

                            Text(
                              _formatDateTime(
                                createdAt,
                              ),
                              style: TextStyle(
                                fontSize: 8.5,
                                height: 1,
                                fontWeight:
                                    FontWeight.w500,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.62,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // =============================================
                    // STATUS
                    // =============================================
                    _StatusBadge(
                      config: config,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // =================================================
                // CUSTOMER / FULFILLMENT
                // =================================================
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CUSTOMER',
                            style: TextStyle(
                              fontSize: 6.5,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: 0.9,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            customerName,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1,
                              fontWeight:
                                  FontWeight.w800,
                              letterSpacing: -0.15,
                              color:
                                  AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    _OrderTypePill(
                      orderType: orderType,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // =================================================
                // SOFT DIVIDER
                // =================================================
                Container(
                  height: 1,
                  color: AppColors.border.withValues(
                    alpha: 0.24,
                  ),
                ),

                const SizedBox(height: 13),

                // =================================================
                // FOOTER
                // =================================================
                Row(
                  children: [
                    // =============================================
                    // ITEMS
                    // =============================================
                    _MetaItem(
                      icon:
                          Icons.shopping_bag_outlined,
                      text:
                          '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                    ),

                    const SizedBox(width: 15),

                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary
                            .withValues(
                          alpha: 0.30,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 15),

                    // =============================================
                    // FULFILLMENT
                    // =============================================
                    _MetaItem(
                      icon: orderType
                                  .toLowerCase() ==
                              'delivery'
                          ? Icons
                              .delivery_dining_outlined
                          : Icons
                              .storefront_outlined,
                      text: orderType
                                  .toLowerCase() ==
                              'delivery'
                          ? 'Delivery'
                          : 'Pickup',
                    ),

                    const Spacer(),

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
                            fontSize: 6,
                            height: 1,
                            fontWeight:
                                FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.42,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          AppHelpers.formatCurrency(
                            total,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: -0.35,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 11),

                    // =============================================
                    // OPEN
                    // =============================================
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius:
                            BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 15,
                        color: Colors.white,
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

  // ============================================================
  // CUSTOMER
  // ============================================================

  String _customerName() {
    final customer = order['customer'];

    if (customer is Map) {
      final String name =
          customer['full_name']
                  ?.toString()
                  .trim() ??
              '';

      if (name.isNotEmpty) {
        return name;
      }
    }

    return 'Customer';
  }

  // ============================================================
  // ITEM COUNT
  // ============================================================

  int _itemCount() {
    final items = order['order_items'];

    if (items is! List) {
      return 0;
    }

    int count = 0;

    for (final item in items) {
      if (item is Map) {
        count +=
            (item['quantity'] as num?)
                    ?.toInt() ??
                0;
      }
    }

    return count;
  }

  // ============================================================
  // TOTAL
  // ============================================================

  double _orderTotal() {
    final double? totalPrice =
        (order['total_price'] as num?)
            ?.toDouble();

    if (totalPrice != null) {
      return totalPrice;
    }

    return (order['total_amount'] as num?)
            ?.toDouble() ??
        0;
  }

  // ============================================================
  // ORDER ID
  // ============================================================

  String _shortOrderId() {
    final String id =
        order['id']?.toString() ?? '';

    if (id.isEmpty) {
      return 'Order';
    }

    final String shortId =
        id.length >= 8
            ? id.substring(0, 8)
            : id;

    return 'Order #${shortId.toUpperCase()}';
  }

  // ============================================================
  // NEW ORDER
  // ============================================================

  bool _isNewOrder(
    DateTime? createdAt,
    String status,
  ) {
    if (createdAt == null ||
        status.toLowerCase() != 'pending') {
      return false;
    }

    final Duration age =
        DateTime.now().difference(createdAt);

    return !age.isNegative &&
        age.inMinutes <= 15;
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDateTime(DateTime date) {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime orderDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final String time =
        DateFormat('h:mm a').format(date);

    if (orderDate == today) {
      return 'Today  •  $time';
    }

    if (orderDate ==
        today.subtract(
          const Duration(days: 1),
        )) {
      return 'Yesterday  •  $time';
    }

    return '${DateFormat('MMM d, yyyy').format(date)}  •  $time';
  }
}

// ===================================================================
// ORDER ICON
// ===================================================================

class _OrderIcon extends StatelessWidget {
  final _OrderStatusConfig config;

  const _OrderIcon({
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: config.color.withValues(
              alpha: 0.09,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            config.icon,
            size: 13,
            color: config.color,
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// NEW BADGE
// ===================================================================

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

// ===================================================================
// STATUS BADGE
// ===================================================================

class _StatusBadge extends StatelessWidget {
  final _OrderStatusConfig config;

  const _StatusBadge({
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(
          alpha: 0.07,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: config.color.withValues(
            alpha: 0.15,
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
              color: config.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.color.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 4,
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Text(
            config.label.toUpperCase(),
            style: TextStyle(
              fontSize: 6.8,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// ORDER TYPE PILL
// ===================================================================

class _OrderTypePill extends StatelessWidget {
  final String orderType;

  const _OrderTypePill({
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    final bool delivery =
        orderType.toLowerCase() == 'delivery';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            delivery
                ? Icons.delivery_dining_outlined
                : Icons.storefront_outlined,
            size: 12,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: 5),

          Text(
            delivery ? 'Delivery' : 'Pickup',
            style: const TextStyle(
              fontSize: 8,
              height: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// META ITEM
// ===================================================================

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary
                .withValues(
              alpha: 0.82,
            ),
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// STATUS CONFIG
// ===================================================================

class _OrderStatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const _OrderStatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

_OrderStatusConfig _statusConfig(
  String status,
) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const _OrderStatusConfig(
        label: 'Pending',
        color: Color(0xFFF59E0B),
        icon: Icons.schedule_rounded,
      );

    case 'accepted':
      return const _OrderStatusConfig(
        label: 'Accepted',
        color: Color(0xFF2563EB),
        icon: Icons.check_rounded,
      );

    case 'preparing':
      return const _OrderStatusConfig(
        label: 'Preparing',
        color: Color(0xFF7C3AED),
        icon: Icons.restaurant_rounded,
      );

    case 'out_for_delivery':
      return const _OrderStatusConfig(
        label: 'On the way',
        color: Color(0xFF0284C7),
        icon: Icons.delivery_dining_rounded,
      );

    case 'ready_for_pickup':
      return const _OrderStatusConfig(
        label: 'Ready',
        color: Color(0xFF059669),
        icon: Icons.shopping_bag_rounded,
      );

    case 'completed':
      return const _OrderStatusConfig(
        label: 'Completed',
        color: AppColors.success,
        icon: Icons.done_all_rounded,
      );

    case 'cancelled':
      return const _OrderStatusConfig(
        label: 'Cancelled',
        color: Color(0xFFDC2626),
        icon: Icons.close_rounded,
      );

    default:
      return const _OrderStatusConfig(
        label: 'Order',
        color: AppColors.textSecondary,
        icon: Icons.receipt_long_rounded,
      );
  }
}