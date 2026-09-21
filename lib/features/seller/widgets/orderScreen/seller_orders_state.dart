import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SellerOrdersLoadingState extends StatelessWidget {
  const SellerOrdersLoadingState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class SellerOrdersErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SellerOrdersErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppConstants.defaultPadding,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(
                  alpha: 0.07,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 27,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Couldn\'t load orders',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SellerOrdersEmptyState extends StatelessWidget {
  final bool hasSearch;
  final String selectedFilter;

  const SellerOrdersEmptyState({
    super.key,
    required this.hasSearch,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    late String title;
    late String subtitle;
    late IconData icon;

    if (hasSearch) {
      title = 'No matching orders';
      subtitle =
          'Try another customer name or order number.';
      icon = Icons.search_off_rounded;
    } else {
      switch (selectedFilter) {
        case 'active':
          title = 'No active orders';
          subtitle =
              'New and ongoing customer orders will appear here.';
          icon = Icons.inbox_outlined;
          break;

        case 'past':
          title = 'No past orders';
          subtitle =
              'Completed and cancelled orders will appear here.';
          icon = Icons.history_rounded;
          break;

        case 'all':
        default:
          title = 'No orders yet';
          subtitle =
              'Customer orders will appear here once they are placed.';
          icon = Icons.receipt_long_outlined;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(
        AppConstants.defaultPadding,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.40,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.025,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 27,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.45,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.75,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}