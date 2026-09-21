import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerPromoHeader extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const SellerPromoHeader({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.40),
            ),
          ),
          child: const Icon(
            Icons.local_offer_outlined,
            size: 22,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MARKETING',
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Promotions',
                style: TextStyle(
                  fontSize: 23,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.75,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your store offers',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.70,
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isRefreshing ? null : onRefresh,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.40),
                ),
              ),
              child: isRefreshing
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      size: 19,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}