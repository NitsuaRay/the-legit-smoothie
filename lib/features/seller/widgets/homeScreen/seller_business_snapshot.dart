import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerBusinessSnapshot extends StatelessWidget {
  final int ordersToday;
  final int completedToday;
  final double todaySales;

  const SellerBusinessSnapshot({
    super.key,
    required this.ordersToday,
    required this.completedToday,
    required this.todaySales,
  });

  double get _averageOrderValue {
    if (completedToday <= 0) {
      return 0;
    }

    return todaySales / completedToday;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),

        const SizedBox(height: 14),

        // =========================================================
        // TODAY METRICS
        // =========================================================

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _SnapshotMetricCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'ORDERS TODAY',
                  value: '$ordersToday',
                  subtitle: ordersToday == 1
                      ? 'Order received today'
                      : 'Orders received today',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _SnapshotMetricCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'COMPLETED',
                  value: '$completedToday',
                  subtitle: completedToday == 1
                      ? 'Order fulfilled today'
                      : 'Orders fulfilled today',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // AVERAGE ORDER VALUE
        // =========================================================

        _buildAverageOrderValue(),
      ],
    );
  }

  // =============================================================
  // HEADER
  // =============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY',
          style: TextStyle(
            fontSize: 8,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: AppColors.textSecondary.withValues(
              alpha: 0.50,
            ),
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Business Snapshot',
          style: TextStyle(
            fontSize: 18,
            height: 1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'A quick look at today\'s store activity.',
          style: TextStyle(
            fontSize: 10,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary.withValues(
              alpha: 0.66,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // AVERAGE ORDER VALUE
  // =============================================================

  Widget _buildAverageOrderValue() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.42,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.022,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // =======================================================
          // ICON
          // =======================================================

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              size: 19,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 12),

          // =======================================================
          // LABEL
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Order Value',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  completedToday == 0
                      ? 'No completed orders yet today'
                      : 'Based on completed orders today',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // =======================================================
          // VALUE
          // =======================================================

          Text(
            '₱${_averageOrderValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SNAPSHOT METRIC CARD
// =================================================================

class _SnapshotMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _SnapshotMetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.42,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.022,
            ),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // ICON
          // =======================================================

          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 22),

          // =======================================================
          // VALUE
          // =======================================================

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // =======================================================
          // LABEL
          // =======================================================

          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          // =======================================================
          // DESCRIPTION
          // =======================================================

          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(
                alpha: 0.64,
              ),
            ),
          ),
        ],
      ),
    );
  }
}