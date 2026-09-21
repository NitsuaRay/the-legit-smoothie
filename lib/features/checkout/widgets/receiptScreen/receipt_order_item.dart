import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class ReceiptOrderItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const ReceiptOrderItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final int quantity =
        (item['quantity'] as num?)?.toInt() ?? 0;

    final double unitPrice =
        (item['unit_price'] as num?)?.toDouble() ?? 0;

    final double totalPrice =
        (item['total_price'] as num?)?.toDouble() ?? 0;

    final String productName =
        item['product_name']?.toString() ?? 'Product';

    final Map<String, List<String>> options =
        _parseOptions(item['selected_options']);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$quantity×',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (options.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  ...options.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '${entry.key}: ${entry.value.join(', ')}',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.35,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                if (unitPrice > 0) ...[
                  const SizedBox(height: 5),
                  Text(
                    '$quantity × ${AppHelpers.formatCurrency(unitPrice)}',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.52),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppHelpers.formatCurrency(totalPrice),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _parseOptions(dynamic rawOptions) {
    final Map<String, List<String>> grouped = {};

    if (rawOptions is! List) return grouped;

    for (final dynamic option in rawOptions) {
      if (option is! Map) continue;

      final String group =
          option['group']?.toString().trim() ?? '';

      final String name =
          option['name']?.toString().trim() ?? '';

      if (name.isEmpty) continue;

      final String safeGroup =
          group.isEmpty ? 'Option' : group;

      grouped.putIfAbsent(safeGroup, () => []);
      grouped[safeGroup]!.add(name);
    }

    return grouped;
  }
}