import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromoSectionCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;
  final Widget child;

  const PromoSectionCard({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppColors.textPrimary.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 5),
            Text(
              description!,
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}