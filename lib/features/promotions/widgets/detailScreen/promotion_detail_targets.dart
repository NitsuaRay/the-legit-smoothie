import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailTargets
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailTargets({
    super.key,
    required this.promotion,
  });

  List<String> get _categories {
    final List<String> result = [];

    final dynamic rows =
        promotion['promotion_categories'];

    if (rows is List) {
      for (final dynamic row in rows) {
        if (row is! Map) continue;

        final dynamic category =
            row['categories'];

        if (category is! Map) continue;

        final String name =
            category['name']
                    ?.toString()
                    .trim() ??
                '';

        if (name.isNotEmpty &&
            !result.contains(name)) {
          result.add(name);
        }
      }
    }

    return result;
  }

  List<String> get _products {
    final List<String> result = [];

    final dynamic rows =
        promotion['promotion_products'];

    if (rows is List) {
      for (final dynamic row in rows) {
        if (row is! Map) continue;

        final dynamic product =
            row['products'];

        if (product is! Map) continue;

        final String name =
            product['name']
                    ?.toString()
                    .trim() ??
                '';

        if (name.isNotEmpty &&
            !result.contains(name)) {
          result.add(name);
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final String appliesTo =
        promotion['applies_to']
                ?.toString()
                .toLowerCase() ??
            '';

    final bool storeWide =
        appliesTo == 'store';

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
          const Text(
            'ELIGIBLE ITEMS',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'What qualifies',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 13),

          if (storeWide)
            const _TargetRow(
              icon: Icons.storefront_outlined,
              title: 'Entire store',
              subtitle:
                  'All available products qualify for this promotion.',
            )
          else ...[
            if (_categories.isNotEmpty) ...[
              const _SmallHeading(
                text: 'CATEGORIES',
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _categories
                    .map(
                      (name) => _Chip(
                        text: name,
                      ),
                    )
                    .toList(),
              ),
            ],

            if (_categories.isNotEmpty &&
                _products.isNotEmpty)
              const SizedBox(height: 18),

            if (_products.isNotEmpty) ...[
              const _SmallHeading(
                text: 'PRODUCTS',
              ),

              const SizedBox(height: 8),

              ..._products.map(
                (name) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 7,
                  ),
                  child: _TargetRow(
                    icon:
                        Icons.local_drink_outlined,
                    title: name,
                    subtitle:
                        'Qualifying product',
                  ),
                ),
              ),
            ],

            if (_categories.isEmpty &&
                _products.isEmpty)
              const _TargetRow(
                icon: Icons.info_outline_rounded,
                title: 'Selected items',
                subtitle:
                    'Qualifying items are determined by this promotion.',
              ),
          ],
        ],
      ),
    );
  }
}

class _SmallHeading extends StatelessWidget {
  final String text;

  const _SmallHeading({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 7,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.9,
        color: AppColors.textSecondary
            .withValues(alpha: 0.65),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TargetRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.textPrimary,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8.5,
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