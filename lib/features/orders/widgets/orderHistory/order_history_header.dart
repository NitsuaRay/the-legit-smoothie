import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderHistoryHeader extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const OrderHistoryHeader({
    super.key,
    this.onRefresh,
    this.isRefreshing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.22),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 19,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ORDERS',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Order history',
                  style: TextStyle(
                    fontSize: 19,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isRefreshing ? null : onRefresh,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.28),
                  ),
                ),
                child: isRefreshing
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}