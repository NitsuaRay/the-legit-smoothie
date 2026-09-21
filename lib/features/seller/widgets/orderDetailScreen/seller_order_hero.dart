import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import 'seller_order_status.dart';

class SellerOrderHero extends StatelessWidget {
  final String orderId;
  final String status;
  final DateTime? createdAt;
  final DateTime? statusChangedAt;

  const SellerOrderHero({
    super.key,
    required this.orderId,
    required this.status,
    required this.createdAt,
    required this.statusChangedAt,
  });

  String get _shortOrderId {
    final shortId = orderId.length >= 6 ? orderId.substring(0, 6) : orderId;

    return '#${shortId.toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final config = sellerOrderStatusConfig(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ORDER IDENTITY
          // =====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.25),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(config.icon, size: 21, color: config.color),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER',
                      style: TextStyle(
                        fontSize: 8,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: AppColors.textSecondary.withValues(alpha: 0.55),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _shortOrderId,
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.45,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (createdAt != null) ...[
                      const SizedBox(height: 6),

                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(createdAt!),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _StatusBadge(status: status),
            ],
          ),

          const SizedBox(height: 18),

          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.28)),

          const SizedBox(height: 17),

          // =====================================================
          // PROGRESS TITLE
          // =====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER PROGRESS',
                      style: TextStyle(
                        fontSize: 8,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.95,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      _progressMessage(status),
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.15,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (statusChangedAt != null) ...[
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.65,
                            ),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            'Updated ${DateFormat('MMM d, yyyy • h:mm a').format(statusChangedAt!)}',
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: config.color.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(config.icon, size: 18, color: config.color),
              ),
            ],
          ),

          const SizedBox(height: 17),

          // =====================================================
          // PROGRESS BAR
          // =====================================================
          _OrderProgressBar(status: status),
        ],
      ),
    );
  }

  String _progressMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting for confirmation';

      case 'accepted':
        return 'Order has been accepted';

      case 'preparing':
        return 'Order is being prepared';

      case 'out_for_delivery':
        return 'Order is on the way';

      case 'ready_for_pickup':
        return 'Order is ready for pickup';

      case 'completed':
        return 'Order completed';

      case 'cancelled':
        return 'Order was cancelled';

      default:
        return 'Order is being processed';
    }
  }
}

// ===================================================================
// PROGRESS BAR
// ===================================================================

class _OrderProgressBar extends StatelessWidget {
  final String status;

  const _OrderProgressBar({required this.status});

  int get _currentStep {
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

      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = status.toLowerCase() == 'cancelled';

    if (isCancelled) {
      return const _CancelledProgress();
    }

    return Row(
      children: List.generate(5, (index) {
        final bool isCompleted = index < _currentStep;

        final bool isCurrent = index == _currentStep;

        return Expanded(
          child: Row(
            children: [
              // ===============================================
              // STEP
              // ===============================================
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isCurrent ? 13 : 10,
                height: isCurrent ? 13 : 10,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.textPrimary
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? AppColors.textPrimary
                        : AppColors.border.withValues(alpha: 0.65),
                    width: isCurrent ? 3 : 1.5,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 7,
                          ),
                        ]
                      : null,
                ),
              ),

              // ===============================================
              // CONNECTOR
              // ===============================================
              if (index < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index < _currentStep
                          ? AppColors.textPrimary
                          : AppColors.border.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ===================================================================
// CANCELLED PROGRESS
// ===================================================================

class _CancelledProgress extends StatelessWidget {
  const _CancelledProgress();

  @override
  Widget build(BuildContext context) {
    const Color color = AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: const Row(
        children: [
          Icon(Icons.cancel_outlined, size: 17, color: color),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'Order processing stopped',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// STATUS BADGE
// ===================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = sellerOrderStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: config.color.withValues(alpha: 0.14)),
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
            ),
          ),

          const SizedBox(width: 5),

          Text(
            config.label.toUpperCase(),
            style: TextStyle(
              fontSize: 7.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.35,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}
