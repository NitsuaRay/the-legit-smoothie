import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class LiveOrderStatus extends StatelessWidget {
  final String status;
  final String orderType;

  const LiveOrderStatus({
    super.key,
    required this.status,
    required this.orderType,
  });

  // ============================================================
  // STATUS INDEX
  // ============================================================
  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;

      case 'accepted':
        return 1;

      case 'preparing':
        return 2;

      case 'out_for_delivery':
      case 'ready_for_pickup':
        return 3;

      case 'completed':
        return 4;

      case 'cancelled':
        return -1;

      default:
        return 0;
    }
  }

  // ============================================================
  // CURRENT STATUS CONFIG
  // ============================================================
  Map<String, dynamic> _getCurrentStatusConfig(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return {
          'title': 'Order Accepted',
          'message':
              'Your order has been confirmed and is now in the queue.',
          'icon': Icons.check_circle_rounded,
          'color': AppColors.primary,
        };

      case 'preparing':
        return {
          'title': 'Preparing Your Order',
          'message':
              'Our team is crafting your drinks and food.',
          'icon': Icons.restaurant_rounded,
          'color': AppColors.secondaryDark,
        };

      case 'out_for_delivery':
        return {
          'title': 'Out for Delivery',
          'message':
              'Your order is on the way to your delivery address.',
          'icon': Icons.delivery_dining_rounded,
          'color': AppColors.primary,
        };

      case 'ready_for_pickup':
        return {
          'title': 'Ready for Pickup',
          'message':
              'Your order is ready and waiting at the store.',
          'icon': Icons.storefront_rounded,
          'color': AppColors.primary,
        };

      case 'completed':
        return {
          'title': 'Order Completed',
          'message':
              'Your order has been successfully completed. Enjoy!',
          'icon': Icons.check_circle_rounded,
          'color': AppColors.success,
        };

      case 'pending':
      default:
        return {
          'title': 'Order Received',
          'message':
              'We have received your order and are waiting for confirmation.',
          'icon': Icons.schedule_rounded,
          'color': AppColors.secondaryDark,
        };
    }
  }

  // ============================================================
  // STEP ICON
  // ============================================================
  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.receipt_long_rounded;

      case 1:
        return Icons.check_circle_outline_rounded;

      case 2:
        return Icons.restaurant_rounded;

      case 3:
        return orderType.toLowerCase() == 'delivery'
            ? Icons.delivery_dining_rounded
            : Icons.storefront_rounded;

      case 4:
        return Icons.verified_rounded;

      default:
        return Icons.circle;
    }
  }

  // ============================================================
  // STEP DATA
  // ============================================================
  List<Map<String, dynamic>> _getSteps() {
    return [
      {
        'title': 'Order Received',
        'desc': 'Your order has been submitted.',
      },
      {
        'title': 'Order Accepted',
        'desc': 'The seller has confirmed your order.',
      },
      {
        'title': 'Preparing',
        'desc': 'Your order is being prepared.',
      },
      {
        'title': orderType.toLowerCase() == 'delivery'
            ? 'Out for Delivery'
            : 'Ready for Pickup',
        'desc': orderType.toLowerCase() == 'delivery'
            ? 'Your order is on its way.'
            : 'Your order is ready at the store.',
      },
      {
        'title': 'Completed',
        'desc': 'Your order has been completed.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final int currentStep = _getStepIndex(status);

    final statusConfig =
        _getCurrentStatusConfig(status);

    final List<Map<String, dynamic>> steps =
        _getSteps();

    final Color statusColor =
        statusConfig['color'] as Color;

    final IconData statusIcon =
        statusConfig['icon'] as IconData;

    final String statusTitle =
        statusConfig['title'] as String;

    final String statusMessage =
        statusConfig['message'] as String;

    // 0 to 100
    final double progress = currentStep < 0
        ? 0
        : currentStep / (steps.length - 1);

    final int progressPercent =
        (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // SECTION HEADER
        // ========================================================
        const Text(
          'Live Order Status',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Track your order as it moves through each stage.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: AppColors.textSecondary.withValues(
              alpha: 0.85,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // CURRENT STATUS HERO
        // ========================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.11),
                statusColor.withValues(alpha: 0.035),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withValues(
                alpha: 0.14,
              ),
            ),
          ),
          child: Column(
            children: [
              // Current Status Row
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(
                            alpha: 0.10,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT STATUS',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: statusColor
                                .withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          statusTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress percentage
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: statusColor.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Text(
                      '$progressPercent%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Current message
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  statusMessage,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // PROGRESS BAR
              // ==================================================
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: progress,
                  ),
                  duration:
                      const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    child,
                  ) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 7,
                      backgroundColor:
                          statusColor.withValues(
                        alpha: 0.10,
                      ),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        statusColor,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 9),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentStep >= 0
                        ? 'Step ${currentStep + 1} of ${steps.length}'
                        : 'Order cancelled',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    currentStep >= 0
                        ? currentStep ==
                                steps.length - 1
                            ? 'Complete'
                            : 'In progress'
                        : 'Cancelled',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ========================================================
        // ORDER PROGRESS
        // ========================================================
        const Text(
          'Order Progress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        // ========================================================
        // TIMELINE CARD
        // ========================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            18,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.55,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              steps.length,
              (index) {
                final bool isDone =
                    index < currentStep;

                final bool isCurrent =
                    index == currentStep;

                final bool isLast =
                    index == steps.length - 1;

                final Color stepColor = isDone ||
                        isCurrent
                    ? statusColor
                    : AppColors.border;

                return Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TIMELINE
                    // ==================================================
                    SizedBox(
                      width: 38,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 350,
                            ),
                            curve: Curves.easeOut,
                            width: isCurrent ? 38 : 34,
                            height: isCurrent ? 38 : 34,
                            decoration: BoxDecoration(
                              color: isDone ||
                                      isCurrent
                                  ? stepColor
                                  : AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stepColor,
                                width:
                                    isCurrent ? 2.5 : 1.8,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: stepColor
                                            .withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_rounded
                                  : _getStepIcon(index),
                              size: isCurrent ? 18 : 16,
                              color: isDone ||
                                      isCurrent
                                  ? Colors.white
                                  : AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.55,
                                  ),
                            ),
                          ),

                          if (!isLast)
                            AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 350,
                              ),
                              width: 2,
                              height: 48,
                              decoration: BoxDecoration(
                                color: index < currentStep
                                    ? statusColor
                                    : AppColors.border
                                        .withValues(
                                        alpha: 0.8,
                                      ),
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ==================================================
                    // STEP CONTENT
                    // ==================================================
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 1,
                          bottom: 16,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 300,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isCurrent ? 12 : 0,
                            vertical:
                                isCurrent ? 10 : 3,
                          ),
                          decoration: isCurrent
                              ? BoxDecoration(
                                  color: statusColor
                                      .withValues(
                                    alpha: 0.065,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                  border: Border.all(
                                    color: statusColor
                                        .withValues(
                                      alpha: 0.10,
                                    ),
                                  ),
                                )
                              : null,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      steps[index]
                                          ['title']!,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: isCurrent
                                            ? FontWeight.w800
                                            : isDone
                                                ? FontWeight.w700
                                                : FontWeight
                                                    .w600,
                                        color: isDone ||
                                                isCurrent
                                            ? AppColors
                                                .textPrimary
                                            : AppColors
                                                .textSecondary,
                                      ),
                                    ),
                                  ),

                                  if (isCurrent)
                                    Container(
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: statusColor
                                            .withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        'NOW',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                          letterSpacing:
                                              0.5,
                                          color:
                                              statusColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(
                                steps[index]['desc']!,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.35,
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha:
                                        isCurrent ? 0.9 : 0.75,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}