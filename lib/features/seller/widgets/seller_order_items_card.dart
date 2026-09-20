import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class SellerOrderItemsCard extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const SellerOrderItemsCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildCard(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              'No order items found.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return _buildCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];

            return Column(
              children: [
                _OrderItem(
                  item: item,
                ),

                if (index != items.length - 1)
                  Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: AppColors.border.withValues(
                      alpha: 0.30,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.40,
          ),
        ),
      ),
      child: child,
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        item['product_name']?.toString() ?? 'Product';

    final int quantity =
        (item['quantity'] as num?)?.toInt() ?? 1;

    final double unitPrice =
        (item['unit_price'] as num?)?.toDouble() ?? 0;

    final double itemTotal =
        (item['total_price'] as num?)?.toDouble() ??
            (unitPrice * quantity);

    final List<Map<String, dynamic>> options =
        _parseSelectedOptions(
      item['selected_options'],
    );

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==============================================
          // QUANTITY
          // ==============================================
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$quantity×',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 11),

          // ==============================================
          // PRODUCT INFO
          // ==============================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${AppHelpers.formatCurrency(unitPrice)} each',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),

                // ========================================
                // SELECTED OPTIONS
                // ========================================
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: options.map((option) {
                      final String optionName =
                          option['name']?.toString() ?? '';

                      final double optionPrice =
                          (option['extra_price'] as num?)
                                  ?.toDouble() ??
                              0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          optionPrice > 0
                              ? '$optionName +${AppHelpers.formatCurrency(optionPrice)}'
                              : optionName,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ==============================================
          // ITEM TOTAL
          // ==============================================
          Text(
            AppHelpers.formatCurrency(itemTotal),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _parseSelectedOptions(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (option) => Map<String, dynamic>.from(
            option,
          ),
        )
        .toList();
  }
}