import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SellerOrdersResultHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int orderCount;

  const SellerOrdersResultHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.orderCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        22,
        AppConstants.defaultPadding,
        12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.30,
                ),
              ),
            ),
            child: Text(
              '$orderCount ${orderCount == 1 ? 'ORDER' : 'ORDERS'}',
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}