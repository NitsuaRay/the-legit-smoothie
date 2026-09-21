import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class OrderTrackingSummary extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> itemsFuture;
  final String orderType;
  final double totalPrice;

  static const double deliveryFeeAmount = 45.00;

  const OrderTrackingSummary({
    super.key,
    required this.itemsFuture,
    required this.orderType,
    required this.totalPrice,
  });

  // ==============================================================
  // SELECTED OPTIONS
  // ==============================================================

  List<Map<String, dynamic>> _parseSelectedOptions(
    dynamic rawOptions,
  ) {
    if (rawOptions == null) {
      return [];
    }

    if (rawOptions is List) {
      return rawOptions
          .whereType<Map>()
          .map(
            (item) =>
                Map<String, dynamic>.from(item),
          )
          .toList();
    }

    if (rawOptions is String &&
        rawOptions.trim().isNotEmpty) {
      try {
        final dynamic decoded =
            jsonDecode(rawOptions);

        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (item) =>
                    Map<String, dynamic>.from(
                  item,
                ),
              )
              .toList();
        }
      } catch (_) {
        return [];
      }
    }

    return [];
  }

  // ==============================================================
  // EXTRA PRICE
  // ==============================================================

  double _getExtraPrice(
    Map<String, dynamic> option,
  ) {
    final dynamic value =
        option['extra_price'];

    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  // ==============================================================
  // OPTION PRICE LABEL
  // ==============================================================

  String _formatOptionPrice(
    double price,
  ) {
    if (price <= 0) {
      return 'Included';
    }

    return '+${AppHelpers.formatCurrency(price)}';
  }

  // ==============================================================
  // OPTION ICON
  // ==============================================================

  IconData _getGroupIcon(
    String group,
  ) {
    switch (group.toLowerCase()) {
      case 'size':
        return Icons.local_drink_outlined;

      case 'sugar level':
      case 'sugar':
        return Icons.water_drop_outlined;

      case 'toppings':
      case 'topping':
        return Icons.add_circle_outline_rounded;

      case 'ice level':
      case 'ice':
        return Icons.ac_unit_rounded;

      case 'milk':
        return Icons.local_cafe_outlined;

      default:
        return Icons.tune_rounded;
    }
  }

  // ==============================================================
  // GROUP OPTIONS
  // ==============================================================

  Map<String, List<Map<String, dynamic>>> _groupOptions(
    List<Map<String, dynamic>> options,
  ) {
    final Map<String, List<Map<String, dynamic>>>
        grouped = {};

    for (final option in options) {
      final String group =
          option['group']?.toString().trim().isNotEmpty ==
                  true
              ? option['group'].toString()
              : 'Options';

      grouped
          .putIfAbsent(group, () => [])
          .add(option);
    }

    return grouped;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDelivery =
        orderType.toLowerCase() == 'delivery';

    final double deliveryFee =
        isDelivery ? deliveryFeeAmount : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // HEADER
        // ==========================================================

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 17,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR ORDER',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.50),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Text(
          'Your items, customizations, and payment breakdown.',
          style: TextStyle(
            fontSize: 10,
            height: 1.4,
            color: AppColors.textSecondary.withValues(
              alpha: 0.72,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // ==========================================================
        // ITEMS
        // ==========================================================

        FutureBuilder<List<Map<String, dynamic>>>(
          future: itemsFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return _LoadingCard();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const _EmptyOrderCard();
            }

            final List<Map<String, dynamic>>
                items = snapshot.data!;

            double itemsSubtotal = 0;

            for (final item in items) {
              itemsSubtotal +=
                  ((item['total_price'] ?? 0)
                          as num)
                      .toDouble();
            }

            return Column(
              children: [
                // ==================================================
                // ITEMS CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border
                          .withValues(
                        alpha: 0.28,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(
                          alpha: 0.022,
                        ),
                        blurRadius: 18,
                        offset:
                            const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(15),
                    itemCount: items.length,
                    separatorBuilder:
                        (context, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        child: Divider(
                          height: 1,
                          color: AppColors.border
                              .withValues(
                            alpha: 0.42,
                          ),
                        ),
                      );
                    },
                    itemBuilder:
                        (context, index) {
                      final Map<String, dynamic>
                          item = items[index];

                      final String itemName =
                          (item['product_name'] ??
                                  'Item')
                              .toString();

                      final int quantity =
                          ((item['quantity'] ?? 1)
                                  as num)
                              .toInt();

                      final double lineTotal =
                          ((item['total_price'] ?? 0)
                                  as num)
                              .toDouble();

                      final dynamic rawOptions =
                          item['selected_options'] ??
                              item['options'] ??
                              item[
                                  'customizations'];

                      final List<
                              Map<String, dynamic>>
                          options =
                          _parseSelectedOptions(
                        rawOptions,
                      );

                      final Map<
                              String,
                              List<
                                  Map<String,
                                      dynamic>>>
                          groupedOptions =
                          _groupOptions(
                        options,
                      );

                      double optionsTotal = 0;

                      for (final option
                          in options) {
                        optionsTotal +=
                            _getExtraPrice(
                          option,
                        );
                      }

                      final double unitTotal =
                          quantity > 0
                              ? lineTotal /
                                  quantity
                              : lineTotal;

                      final double baseUnitPrice =
                          (unitTotal -
                                  optionsTotal)
                              .clamp(
                        0,
                        double.infinity,
                      );

                      return _OrderItem(
                        itemName: itemName,
                        quantity: quantity,
                        lineTotal: lineTotal,
                        baseUnitPrice:
                            baseUnitPrice,
                        groupedOptions:
                            groupedOptions,
                        getExtraPrice:
                            _getExtraPrice,
                        formatOptionPrice:
                            _formatOptionPrice,
                        getGroupIcon:
                            _getGroupIcon,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // TOTAL CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _SummaryPriceRow(
                        label: 'Items subtotal',
                        value:
                            AppHelpers.formatCurrency(
                          itemsSubtotal,
                        ),
                      ),

                      const SizedBox(height: 10),

                      _SummaryPriceRow(
                        label: isDelivery
                            ? 'Delivery fee'
                            : 'Store pickup',
                        value: isDelivery
                            ? AppHelpers
                                .formatCurrency(
                                deliveryFee,
                              )
                            : 'FREE',
                        valueColor:
                            isDelivery
                                ? Colors.white
                                : AppColors.success,
                      ),

                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Divider(
                          height: 1,
                          color: Colors.white
                              .withValues(
                            alpha: 0.12,
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'TOTAL',
                                  style:
                                      TextStyle(
                                    fontSize: 7,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    letterSpacing:
                                        1,
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                          0.48,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Amount paid',
                                  style:
                                      TextStyle(
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight
                                            .w500,
                                    color: Colors
                                        .white
                                        .withValues(
                                      alpha:
                                          0.65,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            AppHelpers
                                .formatCurrency(
                              totalPrice,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 22,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing:
                                  -0.7,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// =================================================================
// ORDER ITEM
// =================================================================

class _OrderItem extends StatelessWidget {
  final String itemName;
  final int quantity;
  final double lineTotal;
  final double baseUnitPrice;

  final Map<String, List<Map<String, dynamic>>>
      groupedOptions;

  final double Function(Map<String, dynamic>)
      getExtraPrice;

  final String Function(double)
      formatOptionPrice;

  final IconData Function(String)
      getGroupIcon;

  const _OrderItem({
    required this.itemName,
    required this.quantity,
    required this.lineTotal,
    required this.baseUnitPrice,
    required this.groupedOptions,
    required this.getExtraPrice,
    required this.formatOptionPrice,
    required this.getGroupIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: Text(
                '${quantity}x',
                style: const TextStyle(
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${AppHelpers.formatCurrency(baseUnitPrice)} each',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Text(
              AppHelpers.formatCurrency(
                lineTotal,
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        // ==========================================================
        // OPTIONS
        // ==========================================================

        if (groupedOptions.isNotEmpty) ...[
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 13,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      'CUSTOMIZATIONS',
                      style: TextStyle(
                        fontSize: 6.5,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ...groupedOptions.entries.map(
                  (entry) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 9,
                      ),
                      child: _OptionGroup(
                        groupName: entry.key,
                        options: entry.value,
                        getExtraPrice:
                            getExtraPrice,
                        formatOptionPrice:
                            formatOptionPrice,
                        icon:
                            getGroupIcon(
                          entry.key,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// =================================================================
// OPTION GROUP
// =================================================================

class _OptionGroup extends StatelessWidget {
  final String groupName;
  final List<Map<String, dynamic>> options;
  final IconData icon;

  final double Function(Map<String, dynamic>)
      getExtraPrice;

  final String Function(double)
      formatOptionPrice;

  const _OptionGroup({
    required this.groupName,
    required this.options,
    required this.icon,
    required this.getExtraPrice,
    required this.formatOptionPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                groupName.toUpperCase(),
                style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 4),

              ...options.map(
                (option) {
                  final String name =
                      (option['name'] ??
                              option[
                                  'option_name'] ??
                              option['value'] ??
                              'Option')
                          .toString();

                  final double extra =
                      getExtraPrice(option);

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 3,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style:
                                const TextStyle(
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w700,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          formatOptionPrice(
                            extra,
                          ),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight:
                                FontWeight.w700,
                            color: extra > 0
                                ? AppColors
                                    .textPrimary
                                : AppColors
                                    .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =================================================================
// SUMMARY ROW
// =================================================================

class _SummaryPriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryPriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(
                alpha: 0.62,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Text(
          value,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color:
                valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// LOADING
// =================================================================

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// EMPTY
// =================================================================

class _EmptyOrderCard extends StatelessWidget {
  const _EmptyOrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 26,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'No item details found',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'The items for this order could not be loaded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              color: AppColors.textSecondary
                  .withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}