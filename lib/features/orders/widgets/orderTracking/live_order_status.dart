import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';

class LiveOrderStatus extends StatefulWidget {
  final String status;
  final String orderType;
  final String orderId;

  const LiveOrderStatus({
    super.key,
    required this.status,
    required this.orderType,
    required this.orderId,
  });

  @override
  State<LiveOrderStatus> createState() => _LiveOrderStatusState();
}

class _LiveOrderStatusState extends State<LiveOrderStatus> {
  List<Map<String, dynamic>> _history = [];

  bool _isLoadingHistory = true;

  late final Stream<List<Map<String, dynamic>>> _historyStream;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _historyStream = supabase
        .from('order_status_history')
        .stream(primaryKey: ['id'])
        .eq('order_id', widget.orderId)
        .order('created_at', ascending: true);

    _loadInitialHistory();
  }

  // ==============================================================
  // INITIAL HISTORY
  // ==============================================================

  Future<void> _loadInitialHistory() async {
    try {
      final response = await supabase
          .from('order_status_history')
          .select(
            'id, order_id, status, changed_by, note, created_at',
          )
          .eq('order_id', widget.orderId)
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        _history = List<Map<String, dynamic>>.from(response);
        _isLoadingHistory = false;
      });
    } catch (e) {
      debugPrint('Failed to load order status history: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  // ==============================================================
  // STATUS INDEX
  // ==============================================================

  int _getStepIndex(String status) {
    final bool isDelivery =
        widget.orderType.toLowerCase() == 'delivery';

    switch (status.toLowerCase()) {
      case 'pending':
        return 0;

      case 'accepted':
        return 1;

      case 'preparing':
        return 2;

      case 'out_for_delivery':
        return isDelivery ? 3 : -1;

      case 'ready_for_pickup':
        return !isDelivery ? 3 : -1;

      case 'completed':
        return 4;

      case 'cancelled':
        return -1;

      default:
        return 0;
    }
  }

  // ==============================================================
  // STATUS CONFIG
  // ==============================================================

  Map<String, dynamic> _getCurrentStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return {
          'title': 'Order Accepted',
          'message':
              'Your order has been confirmed and is now in the queue.',
          'icon': Icons.check_circle_outline_rounded,
          'color': AppColors.primary,
        };

      case 'preparing':
        return {
          'title': 'Preparing Your Order',
          'message':
              'Your drinks and food are currently being prepared.',
          'icon': Icons.restaurant_outlined,
          'color': AppColors.secondaryDark,
        };

      case 'out_for_delivery':
        return {
          'title': 'Out for Delivery',
          'message':
              'Your order has left the store and is on the way.',
          'icon': Icons.delivery_dining_outlined,
          'color': AppColors.primary,
        };

      case 'ready_for_pickup':
        return {
          'title': 'Ready for Pickup',
          'message':
              'Your order is ready. You can now collect it from the store.',
          'icon': Icons.storefront_outlined,
          'color': AppColors.primary,
        };

      case 'completed':
        return {
          'title': 'Order Completed',
          'message':
              'Your order has been successfully completed. Enjoy!',
          'icon': Icons.done_all_rounded,
          'color': AppColors.success,
        };

      case 'pending':
      default:
        return {
          'title': 'Order Received',
          'message':
              'Your order has been received and is waiting for confirmation.',
          'icon': Icons.schedule_outlined,
          'color': AppColors.secondaryDark,
        };
    }
  }

  // ==============================================================
  // STEPS
  // ==============================================================

  List<Map<String, dynamic>> _getSteps() {
    final bool isDelivery =
        widget.orderType.toLowerCase() == 'delivery';

    return [
      {
        'status': 'pending',
        'title': 'Order Received',
        'description': 'We received your order.',
        'icon': Icons.receipt_long_outlined,
      },
      {
        'status': 'accepted',
        'title': 'Order Accepted',
        'description': 'Your order was confirmed.',
        'icon': Icons.check_circle_outline_rounded,
      },
      {
        'status': 'preparing',
        'title': 'Preparing',
        'description': 'Your order is being prepared.',
        'icon': Icons.restaurant_outlined,
      },
      {
        'status':
            isDelivery ? 'out_for_delivery' : 'ready_for_pickup',
        'title':
            isDelivery ? 'Out for Delivery' : 'Ready for Pickup',
        'description': isDelivery
            ? 'Your order is on the way.'
            : 'Your order is ready at the store.',
        'icon': isDelivery
            ? Icons.delivery_dining_outlined
            : Icons.storefront_outlined,
      },
      {
        'status': 'completed',
        'title': 'Completed',
        'description': isDelivery
            ? 'Your order has been delivered.'
            : 'Your order has been picked up.',
        'icon': Icons.done_all_rounded,
      },
    ];
  }

  // ==============================================================
  // HISTORY DATE
  // ==============================================================

  DateTime? _getHistoryDate(String status) {
    for (final row in _history.reversed) {
      if ((row['status'] ?? '').toString().toLowerCase() ==
          status.toLowerCase()) {
        final dynamic value = row['created_at'];

        if (value == null) {
          return null;
        }

        try {
          return DateTime.parse(value.toString()).toLocal();
        } catch (_) {
          return null;
        }
      }
    }

    return null;
  }

  String _formatStatusTime(DateTime date) {
    int hour = date.hour;

    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = hour >= 12 ? 'PM' : 'AM';

    hour %= 12;

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  String _formatStatusDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ==============================================================
  // REALTIME HISTORY
  // ==============================================================

  void _handleRealtimeHistory(
    List<Map<String, dynamic>> realtimeRows,
  ) {
    // Prevent a temporary empty realtime emission from
    // removing history that was already loaded successfully.
    if (realtimeRows.isEmpty && _history.isNotEmpty) {
      return;
    }

    if (!_sameHistory(_history, realtimeRows)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _history = List<Map<String, dynamic>>.from(
            realtimeRows,
          );
        });
      });
    }
  }

  bool _sameHistory(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i]['id'] != b[i]['id'] ||
          a[i]['status'] != b[i]['status'] ||
          a[i]['created_at'] != b[i]['created_at']) {
        return false;
      }
    }

    return true;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final int currentStep = _getStepIndex(widget.status);

    final Map<String, dynamic> statusConfig =
        _getCurrentStatusConfig(widget.status);

    final List<Map<String, dynamic>> steps = _getSteps();

    final Color statusColor =
        statusConfig['color'] as Color;

    final IconData statusIcon =
        statusConfig['icon'] as IconData;

    final String statusTitle =
        statusConfig['title'] as String;

    final String statusMessage =
        statusConfig['message'] as String;

    final double progress = currentStep < 0
        ? 0
        : ((currentStep + 1) / steps.length)
            .clamp(0.0, 1.0);

    final int progressPercent =
        (progress * 100).round();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _historyStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _handleRealtimeHistory(snapshot.data!);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // SECTION HEADER
            // ======================================================

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.route_outlined,
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
                        'LIVE STATUS',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          color: AppColors.textSecondary
                              .withValues(alpha: 0.50),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Order progress',
                        style: TextStyle(
                          fontSize: 18,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Text(
              'Follow each stage as your order is processed.',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.72,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ======================================================
            // CURRENT STATUS
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
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
                    blurRadius: 20,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT STATUS',
                              style: TextStyle(
                                fontSize: 6.5,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 0.9,
                                color: statusColor
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              statusTitle,
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
                          color: statusColor.withValues(
                            alpha: 0.07,
                          ),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$progressPercent%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary
                            .withValues(alpha: 0.78),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child:
                        TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: progress,
                      ),
                      duration: const Duration(
                        milliseconds: 550,
                      ),
                      curve: Curves.easeOutCubic,
                      builder: (
                        context,
                        value,
                        child,
                      ) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.background,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ======================================================
            // TIMELINE
            // ======================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                15,
                17,
                15,
                17,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.28,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER JOURNEY',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (_isLoadingHistory)
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      steps.length,
                      (index) {
                        final step = steps[index];

                        final String stepStatus =
                            step['status'] as String;

                        final String title =
                            step['title'] as String;

                        final String description =
                            step['description']
                                as String;

                        final IconData icon =
                            step['icon'] as IconData;

                        final bool isCompleted =
                            currentStep >= index &&
                                currentStep >= 0;

                        final bool isCurrent =
                            currentStep == index;

                        final bool hasNext =
                            index < steps.length - 1;

                        final DateTime? reachedAt =
                            _getHistoryDate(
                          stepStatus,
                        );

                        return _TimelineStep(
                          title: title,
                          description: description,
                          icon: icon,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          hasNext: hasNext,
                          reachedAt: reachedAt,
                          formatDate:
                              _formatStatusDate,
                          formatTime:
                              _formatStatusTime,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =================================================================
// TIMELINE STEP
// =================================================================

class _TimelineStep extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  final bool isCompleted;
  final bool isCurrent;
  final bool hasNext;

  final DateTime? reachedAt;

  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isCurrent,
    required this.hasNext,
    required this.reachedAt,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
        AppColors.textPrimary;

    final Color inactiveColor =
        AppColors.textSecondary.withValues(
      alpha: 0.35,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          // ========================================================
          // TIMELINE INDICATOR
          // ========================================================

          SizedBox(
            width: 36,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? activeColor
                        : AppColors.background,
                    borderRadius:
                        BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? activeColor
                          : AppColors.border.withValues(
                              alpha: 0.45,
                            ),
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 12,
                              offset:
                                  const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted
                        ? (isCurrent
                            ? icon
                            : Icons.check_rounded)
                        : icon,
                    size: 15,
                    color: isCompleted
                        ? Colors.white
                        : inactiveColor,
                  ),
                ),

                if (hasNext)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      color: isCompleted
                          ? AppColors.textPrimary
                              .withValues(alpha: 0.25)
                          : AppColors.border.withValues(
                              alpha: 0.35,
                            ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ========================================================
          // CONTENT
          // ========================================================

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: hasNext ? 18 : 0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isCompleted
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isCompleted
                                ? AppColors.textPrimary
                                : AppColors
                                    .textSecondary
                                    .withValues(
                                    alpha: 0.52,
                                  ),
                          ),
                        ),
                      ),

                      if (isCurrent)
                        Container(
                          margin: const EdgeInsets.only(
                            left: 7,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors
                                .textPrimary,
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              fontSize: 6,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.4,
                      color: AppColors.textSecondary
                          .withValues(
                        alpha:
                            isCompleted ? 0.70 : 0.42,
                      ),
                    ),
                  ),

                  if (reachedAt != null) ...[
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors
                              .textSecondary
                              .withValues(alpha: 0.55),
                        ),

                        const SizedBox(width: 4),

                        Flexible(
                          child: Text(
                            '${formatDate(reachedAt!)} • '
                            '${formatTime(reachedAt!)}',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight:
                                  FontWeight.w600,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.62,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}