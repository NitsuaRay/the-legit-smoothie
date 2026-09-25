import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesEmptyState
    extends StatelessWidget {
  const SellerSalesEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 34,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.38,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'No sales yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Completed orders will appear '
            'here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary
                  .withValues(
                alpha: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}