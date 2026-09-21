import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerPromoEmptyState extends StatelessWidget {
  final bool searching;
  final VoidCallback onCreate;

  const SellerPromoEmptyState({
    super.key,
    required this.searching,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                size: 26,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No promotions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              searching
                  ? 'Try another search or filter.'
                  : 'Create a promotion to start offering deals to your customers.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            if (!searching) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Create Promotion',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}