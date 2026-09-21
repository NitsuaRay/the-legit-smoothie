import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderTrackingCancelledCard
    extends StatelessWidget {
  final String? cancelReason;

  const OrderTrackingCancelledCard({
    super.key,
    required this.cancelReason,
  });

  @override
  Widget build(BuildContext context) {
    final String reason =
        cancelReason?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 19,
              color: AppColors.error,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ORDER CANCELLED',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.error,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'This order was cancelled',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}