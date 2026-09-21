import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerPromoStatusBadge extends StatelessWidget {
  final String status;

  const SellerPromoStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final String label = switch (status) {
      'active' => 'ACTIVE',
      'upcoming' => 'UPCOMING',
      'expired' => 'EXPIRED',
      _ => 'DISABLED',
    };

    final bool active = status == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.textPrimary
            : AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: active
              ? AppColors.textPrimary
              : AppColors.border.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.55,
          color: active
              ? Colors.white
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}