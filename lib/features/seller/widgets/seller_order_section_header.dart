import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SellerOrderSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const SellerOrderSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 9.5,
            color: AppColors.textSecondary.withValues(
              alpha: 0.72,
            ),
          ),
        ),
      ],
    );
  }
}