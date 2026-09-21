import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderTrackingAppHeader extends StatelessWidget {
  const OrderTrackingAppHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(13),
              child: Ink(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.32,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
              ),
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
                    fontSize: 7,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Track order',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.65,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Follow your order in real time',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.near_me_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}