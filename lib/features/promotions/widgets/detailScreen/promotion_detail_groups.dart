import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailGroups
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailGroups({
    super.key,
    required this.promotion,
  });

  List<Map<String, dynamic>> get _groups {
    final dynamic raw =
        promotion['promotion_groups'];

    if (raw is! List) {
      return [];
    }

    final groups = raw
        .whereType<Map>()
        .map(
          (group) =>
              Map<String, dynamic>.from(group),
        )
        .toList();

    groups.sort(
      (a, b) =>
          ((a['sort_order'] as num?)
                      ?.toInt() ??
                  0)
              .compareTo(
        (b['sort_order'] as num?)
                ?.toInt() ??
            0,
      ),
    );

    return groups;
  }

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
          const Text(
            'MIX & MATCH',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Build your deal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Complete every group below to qualify.',
            style: TextStyle(
              fontSize: 9.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 14),

          for (
            int index = 0;
            index < _groups.length;
            index++
          ) ...[
            _GroupCard(
              index: index,
              group: _groups[index],
            ),

            if (index != _groups.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> group;

  const _GroupCard({
    required this.index,
    required this.group,
  });

  int get _quantity {
    return (group['required_quantity']
                as num?)
            ?.toInt() ??
        1;
  }

  String get _name {
    final String value =
        group['name']?.toString().trim() ??
            '';

    return value.isEmpty
        ? 'Group ${index + 1}'
        : value;
  }

  List<String> get _targets {
    final List<String> result = [];

    final dynamic categories =
        group['promotion_group_categories'];

    if (categories is List) {
      for (final dynamic row in categories) {
        if (row is! Map) continue;

        final dynamic category =
            row['categories'];

        if (category is Map) {
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
    }

    final dynamic products =
        group['promotion_group_products'];

    if (products is List) {
      for (final dynamic row in products) {
        if (row is! Map) continue;

        final dynamic product =
            row['products'];

        if (product is Map) {
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
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Choose $_quantity '
                  '${_quantity == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                if (_targets.isNotEmpty) ...[
                  const SizedBox(height: 9),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _targets
                        .map(
                          (target) =>
                              _GroupTarget(
                            text: target,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTarget extends StatelessWidget {
  final String text;

  const _GroupTarget({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}