import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailCriteria
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailCriteria({
    super.key,
    required this.promotion,
  });

  double get _minimumOrder {
    return (promotion['minimum_order_amount']
                as num?)
            ?.toDouble() ??
        0;
  }

  int get _minimumQuantity {
    return (promotion['minimum_quantity']
                as num?)
            ?.toInt() ??
        0;
  }

  int? get _maxApplications {
    final dynamic value =
        promotion[
            'max_applications_per_order'];

    if (value == null) return null;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  bool get _discountOptions {
    return promotion['discount_options'] ==
        true;
  }

  bool get _isMixAndMatch {
    return promotion['promotion_type']
            ?.toString() ==
        'mix_and_match';
  }

  @override
  Widget build(BuildContext context) {
    final List<_Criterion> criteria = [];

    if (_minimumOrder > 0) {
      criteria.add(
        _Criterion(
          icon: Icons.payments_outlined,
          title: 'Minimum order',
          description:
              'Spend at least ₱${_minimumOrder.toStringAsFixed(2)} '
              'on qualifying items.',
        ),
      );
    }

    if (_minimumQuantity > 0) {
      criteria.add(
        _Criterion(
          icon: Icons.shopping_bag_outlined,
          title: 'Minimum quantity',
          description:
              'Add at least $_minimumQuantity qualifying '
              '${_minimumQuantity == 1 ? 'item' : 'items'}.',
        ),
      );
    }

    if (_isMixAndMatch) {
      criteria.add(
        const _Criterion(
          icon: Icons.dashboard_customize_outlined,
          title: 'Complete the required groups',
          description:
              'Choose the required number of qualifying '
              'items from each group shown below.',
        ),
      );
    }

    if (_maxApplications != null) {
      criteria.add(
        _Criterion(
          icon: Icons.repeat_rounded,
          title: 'Application limit',
          description:
              'This deal can be applied up to '
              '$_maxApplications '
              '${_maxApplications == 1 ? 'time' : 'times'} '
              'per order.',
        ),
      );
    } else if (_isMixAndMatch) {
      criteria.add(
        const _Criterion(
          icon: Icons.repeat_rounded,
          title: 'Repeatable deal',
          description:
              'The deal may apply multiple times when '
              'your cart contains enough qualifying items.',
        ),
      );
    }

    criteria.add(
      _Criterion(
        icon: Icons.tune_rounded,
        title: 'Product options',
        description: _discountOptions
            ? 'Selected product options can be included '
                'when calculating the promotion discount.'
            : 'Product add-ons and option charges are not '
                'included in the promotional discount.',
      ),
    );

    return _SectionCard(
      eyebrow: 'HOW TO QUALIFY',
      title: 'Promotion criteria',
      icon: Icons.checklist_rounded,
      child: Column(
        children: [
          for (
            int i = 0;
            i < criteria.length;
            i++
          ) ...[
            _CriteriaRow(
              criterion: criteria[i],
            ),

            if (i != criteria.length - 1)
              const _Divider(),
          ],
        ],
      ),
    );
  }
}

class _Criterion {
  final IconData icon;
  final String title;
  final String description;

  const _Criterion({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _CriteriaRow extends StatelessWidget {
  final _Criterion criterion;

  const _CriteriaRow({
    required this.criterion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Icon(
              criterion.icon,
              size: 17,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  criterion.title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  criterion.description,
                  style: const TextStyle(
                    fontSize: 9.5,
                    height: 1.4,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.eyebrow,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
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
                size: 16,
                color: AppColors.textPrimary,
              ),

              const SizedBox(width: 7),

              Text(
                eyebrow,
                style: const TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.border.withValues(
        alpha: 0.22,
      ),
    );
  }
}