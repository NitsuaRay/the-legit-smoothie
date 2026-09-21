import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailOverview
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailOverview({
    super.key,
    required this.promotion,
  });

  String get _discountText {
    final String type =
        promotion['discount_type']
                ?.toString()
                .toLowerCase() ??
            '';

    final double value =
        (promotion['discount_value'] as num?)
                ?.toDouble() ??
            0;

    switch (type) {
      case 'percentage':
        return '${_number(value)}% OFF';

      case 'fixed_amount':
        return '₱${value.toStringAsFixed(2)} OFF';

      case 'fixed_price':
        return '₱${value.toStringAsFixed(2)}';

      default:
        return promotion['discount_tag']
                ?.toString() ??
            'Special deal';
    }
  }

  String get _typeText {
    final String type =
        promotion['promotion_type']
                ?.toString() ??
            '';

    if (type == 'mix_and_match') {
      return 'Mix & Match';
    }

    return 'Promotion';
  }

  String _number(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _OverviewBox(
            eyebrow: 'DEAL',
            value: _discountText,
            icon: Icons.sell_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _OverviewBox(
            eyebrow: 'TYPE',
            value: _typeText,
            icon: Icons.tune_rounded,
          ),
        ),
      ],
    );
  }
}

class _OverviewBox extends StatelessWidget {
  final String eyebrow;
  final String value;
  final IconData icon;

  const _OverviewBox({
    required this.eyebrow,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 91,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.textSecondary,
              ),

              const SizedBox(width: 6),

              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}