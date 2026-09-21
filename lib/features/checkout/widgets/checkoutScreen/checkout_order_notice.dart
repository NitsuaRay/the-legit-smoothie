import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CheckoutOrderNotice extends StatelessWidget {
  final String orderType;

  const CheckoutOrderNotice({
    super.key,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Before placing your order',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Please make sure your contact information, '
                  '${orderType == 'delivery' ? 'delivery address, ' : ''}'
                  'items, and instructions are correct.',
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}