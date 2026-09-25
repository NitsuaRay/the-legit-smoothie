import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesHistoryHeader extends StatelessWidget {
  final bool isMonthly;

  const SellerSalesHistoryHeader({
    super.key,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =======================================================
        // ICON
        // =======================================================

        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.query_stats_rounded,
            size: 19,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 12),

        // =======================================================
        // TITLE
        // =======================================================

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SALES PERFORMANCE',
                style: TextStyle(
                  fontSize: 7.5,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.05,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Sales History',
                style: TextStyle(
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.55,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                isMonthly
                    ? 'Monthly revenue and completed order performance.'
                    : 'Daily revenue and completed order performance.',
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}