import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderHistoryEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final bool isSearching;

  const OrderHistoryEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 50, 28, 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_outlined,
                size: 28,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isSearching ? 'NO RESULTS' : 'YOUR ORDERS',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.15,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}