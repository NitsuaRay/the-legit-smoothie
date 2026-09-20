import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SellerOrderCancellationCard
    extends StatelessWidget {
  final String reason;

  const SellerOrderCancellationCard({
    super.key,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: 0.055,
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================================
          // ICON
          // ==============================================
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 19,
              color: AppColors.error,
            ),
          ),

          const SizedBox(width: 10),

          // ==============================================
          // CONTENT
          // ==============================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Cancelled',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),

                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 9.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),

                  const Text(
                    'No cancellation reason was provided.',
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.4,
                      color: AppColors.textSecondary,
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