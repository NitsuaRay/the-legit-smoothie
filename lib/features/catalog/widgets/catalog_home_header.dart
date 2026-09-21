import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CatalogHomeHeader extends StatelessWidget {
  final bool isStoreOpen;

  const CatalogHomeHeader({super.key, required this.isStoreOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        18,
        AppConstants.defaultPadding,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // BRAND
          // =====================================================
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.30),
                  ),
                ),
                child: Image.asset(
                  'assets/logoSmoothie.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_drink_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    );
                  },
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THE LEGIT SMOOTHIE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Freshly made. Made for you.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              _StoreStatus(isOpen: isStoreOpen),
            ],
          ),

          const SizedBox(height: 26),

          // =====================================================
          // GREETING
          // =====================================================
          Text(
            _greeting.toUpperCase(),
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textSecondary.withValues(alpha: 0.58),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'What are you\ncraving today?',
            style: TextStyle(
              fontSize: 30,
              height: 1.03,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Smoothies, milk tea, fresh juice and '
            'snacks made for every craving.',
            style: TextStyle(
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final int hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }
}

class _StoreStatus extends StatelessWidget {
  final bool isOpen;

  const _StoreStatus({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOpen
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: const TextStyle(
              fontSize: 9.5, // increased from 7
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
