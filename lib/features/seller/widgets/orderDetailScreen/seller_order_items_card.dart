import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class SellerOrderItemsCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  final double originalSubtotal;
  final double discountAmount;
  final String? promotionTitle;
  final int promotionApplications;

  const SellerOrderItemsCard({
    super.key,
    required this.items,
    required this.originalSubtotal,
    required this.discountAmount,
    this.promotionTitle,
    this.promotionApplications = 0,
  });



  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              'No order items found.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ...List.generate(items.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _OrderItem(item: items[index], itemNumber: index + 1),
          );
        }),
      ],
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ============================================================
// ORDER ITEM
// ============================================================

class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int itemNumber;

  const _OrderItem({required this.item, required this.itemNumber});

  @override
  Widget build(BuildContext context) {
    final String name = item['product_name']?.toString().trim() ?? 'Product';

    final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;

    final double unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0;

    final double itemTotal =
        (item['total_price'] as num?)?.toDouble() ?? (unitPrice * quantity);

    final List<Map<String, dynamic>> options = _parseSelectedOptions(
      item['selected_options'],
    );

    final Map<String, List<Map<String, dynamic>>> groupedOptions =
        _groupOptions(options);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // PRODUCT HEADER
          // =====================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // QUANTITY
                // =================================================
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$quantity×',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                // =================================================
                // PRODUCT NAME
                // =================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ITEM $itemNumber',
                        style: TextStyle(
                          fontSize: 7.5,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.25,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${AppHelpers.formatCurrency(unitPrice)} each',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // =================================================
                // TOTAL
                // =================================================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textSecondary.withValues(alpha: 0.50),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      AppHelpers.formatCurrency(itemTotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // =====================================================
          // OPTIONS
          // =====================================================
          if (options.isNotEmpty) ...[
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.30)),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.55),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===============================================
                  // CUSTOMIZATION HEADER
                  // ===============================================
                  Row(
                    children: [
                      Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 9),

                      const Text(
                        'Customizations',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  // ===============================================
                  // OPTION GROUPS
                  // ===============================================
                  ...groupedOptions.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _OptionGroup(
                        group: entry.key,
                        options: entry.value,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // PARSE OPTIONS
  // ============================================================

  List<Map<String, dynamic>> _parseSelectedOptions(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map((option) => Map<String, dynamic>.from(option))
        .toList();
  }

  // ============================================================
  // GROUP OPTIONS
  // ============================================================

  Map<String, List<Map<String, dynamic>>> _groupOptions(
    List<Map<String, dynamic>> options,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final option in options) {
      final String group = _optionGroup(option);

      grouped.putIfAbsent(group, () => []);

      grouped[group]!.add(option);
    }

    return grouped;
  }

  // ============================================================
  // OPTION GROUP
  // ============================================================

  String _optionGroup(Map<String, dynamic> option) {
    // Support the common keys in case the
    // checkout snapshot uses either naming style.
    final String rawGroup =
        option['option_group']?.toString().trim() ??
        option['group']?.toString().trim() ??
        '';

    if (rawGroup.isEmpty) {
      return 'Options';
    }

    return _formatLabel(rawGroup);
  }

  // ============================================================
  // FORMAT LABEL
  // ============================================================

  String _formatLabel(String value) {
    if (value.trim().isEmpty) {
      return 'Options';
    }

    return value
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }
}

// ============================================================
// OPTION GROUP
// ============================================================

class _OptionGroup extends StatelessWidget {
  final String group;
  final List<Map<String, dynamic>> options;

  const _OptionGroup({required this.group, required this.options});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =======================================================
        // GROUP
        // =======================================================
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              group.toUpperCase(),
              style: TextStyle(
                fontSize: 7.5,
                height: 1.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.textSecondary.withValues(alpha: 0.58),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // =======================================================
        // VALUES
        // =======================================================
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.map((option) {
              final String optionName = _optionName(option);

              final double optionPrice = _optionPrice(option);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      optionName,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    if (optionPrice > 0) ...[
                      const SizedBox(width: 5),

                      Text(
                        '+${AppHelpers.formatCurrency(optionPrice)}',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _optionName(Map<String, dynamic> option) {
    final String name =
        option['name']?.toString().trim() ??
        option['option_name']?.toString().trim() ??
        '';

    return name.isEmpty ? 'Option' : name;
  }

  double _optionPrice(Map<String, dynamic> option) {
    final dynamic value = option['extra_price'] ?? option['price'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
