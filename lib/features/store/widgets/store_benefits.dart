import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreBenefits extends StatelessWidget {
  const StoreBenefits({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.border.withValues(
              alpha: 0.28,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.035,
              ),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            // ===================================================
            // FRESH
            // ===================================================

            Expanded(
              child: _BenefitCard(
                number: '01',
                icon: Icons.eco_rounded,
                title: 'Fresh',
                subtitle: 'Quality ingredients',
              ),
            ),

            _BenefitDivider(),

            // ===================================================
            // MADE FRESH
            // ===================================================

            Expanded(
              child: _BenefitCard(
                number: '02',
                icon: Icons.local_drink_rounded,
                title: 'Made Fresh',
                subtitle: 'Prepared to order',
              ),
            ),

            _BenefitDivider(),

            // ===================================================
            // CONVENIENT
            // ===================================================

            Expanded(
              child: _BenefitCard(
                number: '03',
                icon: Icons.delivery_dining_rounded,
                title: 'Convenient',
                subtitle: 'Pickup or delivery',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// BENEFIT CARD
// =================================================================

class _BenefitCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 145,
      ),
      padding: const EdgeInsets.fromLTRB(
        11,
        12,
        10,
        13,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ICON + NUMBER
          // =====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.09,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              Text(
                number,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // =====================================================
          // TITLE
          // =====================================================

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 7),

          // =====================================================
          // DESCRIPTION
          // =====================================================

          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(
                alpha: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// DIVIDER
// =================================================================

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Container(
        width: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.border.withValues(
                alpha: 0.55,
              ),
              AppColors.border.withValues(
                alpha: 0.55,
              ),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}