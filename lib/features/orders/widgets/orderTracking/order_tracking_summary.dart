import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';

class OrderTrackingSummary extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> itemsFuture;

  final String orderType;

  /// Discounted subtotal stored on the order.
  final double subtotal;

  /// Actual delivery fee stored on the order.
  final double deliveryFee;

  /// Final amount paid.
  final double totalPrice;

  /// Promotion discount stored on the order.
  final double discountAmount;

  /// Historical promotion title stored on the order.
  final String? promotionTitle;

  /// Historical promotion snapshot stored on the order.
  final dynamic promotionSnapshot;

  const OrderTrackingSummary({
    super.key,
    required this.itemsFuture,
    required this.orderType,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalPrice,
    required this.discountAmount,
    this.promotionTitle,
    this.promotionSnapshot,
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
          option['option_group']
                      ?.toString()
                      .trim()
                      .isNotEmpty ==
                  true
              ? option['option_group'].toString()
              : option['group']
                          ?.toString()
                          .trim()
                          .isNotEmpty ==
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
  // PROMOTION
  // ==============================================================

  bool get _hasPromotion {
    return discountAmount > 0;
  }

  String get _promotionName {
    final String title =
        promotionTitle?.trim() ?? '';

    if (title.isNotEmpty) {
      return title;
    }

    return 'Promotion Discount';
  }

  Map<String, dynamic>? get _promotionData {
    final dynamic raw =
        promotionSnapshot;

    if (raw == null) {
      return null;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw,
      );
    }

    if (raw is String &&
        raw.trim().isNotEmpty) {
      try {
        final dynamic decoded =
            jsonDecode(raw);

        if (decoded is Map) {
          return Map<String, dynamic>.from(
            decoded,
          );
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  int get _promotionApplications {
    final Map<String, dynamic>? data =
        _promotionData;

    if (data == null) {
      return 0;
    }

    final dynamic raw =
        data['applications'];

    if (raw is num) {
      return raw.toInt();
    }

    return int.tryParse(
          raw?.toString() ?? '',
        ) ??
        0;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDelivery =
        orderType.toLowerCase() ==
            'delivery';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: -0.4,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Text(
          'Your items, customizations, promotion, and payment breakdown.',
          style: TextStyle(
            fontSize: 10,
            height: 1.4,
            color: AppColors.textSecondary
                .withValues(
              alpha: 0.72,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // ==========================================================
        // ITEMS
        // ==========================================================

        FutureBuilder<
            List<Map<String, dynamic>>>(
          future: itemsFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingCard();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const _EmptyOrderCard();
            }

            final List<Map<String, dynamic>>
                items = snapshot.data!;

            // ======================================================
            // ORIGINAL ITEMS SUBTOTAL
            // ======================================================
            //
            // order_items.total_price contains the original item
            // totals before the promotion discount.
            // ======================================================

            double itemsSubtotal = 0;

            for (final item in items) {
              final dynamic rawTotal =
                  item['total_price'];

              if (rawTotal is num) {
                itemsSubtotal +=
                    rawTotal.toDouble();
              } else {
                itemsSubtotal +=
                    double.tryParse(
                          rawTotal
                                  ?.toString() ??
                              '',
                        ) ??
                        0;
              }
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
                            const EdgeInsets
                                .symmetric(
                          vertical: 15,
                        ),
                        child: Divider(
                          height: 1,
                          color: AppColors
                              .border
                              .withValues(
                            alpha: 0.42,
                          ),
                        ),
                      );
                    },
                    itemBuilder:
                        (context, index) {
                      final Map<String, dynamic>
                          item =
                          items[index];

                      final String itemName =
                          (item['product_name'] ??
                                  'Item')
                              .toString();

                      final int quantity =
                          _parseInt(
                        item['quantity'],
                        fallback: 1,
                      );

                      final double lineTotal =
                          _parseDouble(
                        item['total_price'],
                      );

                      final dynamic rawOptions =
                          item[
                                  'selected_options'] ??
                              item['options'] ??
                              item[
                                  'customizations'];

                      final List<
                              Map<String,
                                  dynamic>>
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

                      final double
                          baseUnitPrice =
                          (unitTotal -
                                  optionsTotal)
                              .clamp(
                        0,
                        double.infinity,
                      );

                      return _OrderItem(
                        itemName:
                            itemName,
                        quantity:
                            quantity,
                        lineTotal:
                            lineTotal,
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

                // ==================================================
                // PROMOTION APPLIED
                // ==================================================

                if (_hasPromotion) ...[
                  const SizedBox(
                    height: 12,
                  ),

                  _PromotionAppliedCard(
                    promotionTitle:
                        _promotionName,
                    discountAmount:
                        discountAmount,
                    applications:
                        _promotionApplications,
                  ),
                ],

                const SizedBox(height: 12),

                // ==================================================
                // TOTAL CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        AppColors.textPrimary,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      // ============================================
                      // ORIGINAL SUBTOTAL
                      // ============================================

                      _SummaryPriceRow(
                        label:
                            'Items subtotal',
                        value: AppHelpers
                            .formatCurrency(
                          itemsSubtotal,
                        ),
                      ),

                      // ============================================
                      // PROMOTION DISCOUNT
                      // ============================================

                      if (_hasPromotion) ...[
                        const SizedBox(
                          height: 10,
                        ),

                        _SummaryPriceRow(
                          label:
                              _promotionName,
                          value:
                              '-${AppHelpers.formatCurrency(discountAmount)}',
                          valueColor:
                              AppColors.success,
                        ),
                      ],

                      // ============================================
                      // DELIVERY / PICKUP
                      // ============================================

                      const SizedBox(
                        height: 10,
                      ),

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
                                : AppColors
                                    .success,
                      ),

                      // ============================================
                      // DISCOUNTED SUBTOTAL
                      // ============================================

                      if (_hasPromotion) ...[
                        const SizedBox(
                          height: 10,
                        ),

                        _SummaryPriceRow(
                          label:
                              'After discount',
                          value: AppHelpers
                              .formatCurrency(
                            subtotal,
                          ),
                        ),
                      ],

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
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

                      // ============================================
                      // FINAL TOTAL
                      // ============================================

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
                                    fontSize:
                                        9,
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

                          const SizedBox(
                            width: 12,
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
                                  FontWeight
                                      .w900,
                              letterSpacing:
                                  -0.7,
                              color:
                                  Colors.white,
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

  // ==============================================================
  // HELPERS
  // ==============================================================

  double _parseDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  int _parseInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        fallback;
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

  final Map<
      String,
      List<Map<String, dynamic>>>
      groupedOptions;

  final double Function(
    Map<String, dynamic>,
  ) getExtraPrice;

  final String Function(
    double,
  ) formatOptionPrice;

  final IconData Function(
    String,
  ) getGroupIcon;

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
                color:
                    AppColors.textPrimary,
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: Text(
                '${quantity}x',
                style:
                    const TextStyle(
                  fontSize: 9,
                  height: 1,
                  fontWeight:
                      FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    itemName,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          -0.2,
                      color: AppColors
                          .textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    '${AppHelpers.formatCurrency(baseUnitPrice)} each',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight:
                          FontWeight.w500,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.68,
                      ),
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
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ],
        ),

        // ==========================================================
        // OPTIONS
        // ==========================================================

        if (groupedOptions
            .isNotEmpty) ...[
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 27,
                      height: 27,
                      decoration:
                          BoxDecoration(
                        color: AppColors
                            .surface,
                        borderRadius:
                            BorderRadius
                                .circular(
                          8,
                        ),
                      ),
                      child:
                          const Icon(
                        Icons
                            .tune_rounded,
                        size: 13,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Text(
                      'CUSTOMIZATIONS',
                      style:
                          TextStyle(
                        fontSize: 6.5,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            0.8,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                ...groupedOptions
                    .entries
                    .map(
                  (entry) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 9,
                      ),
                      child:
                          _OptionGroup(
                        groupName:
                            entry.key,
                        options:
                            entry.value,
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

class _OptionGroup
    extends StatelessWidget {
  final String groupName;

  final List<Map<String, dynamic>>
      options;

  final IconData icon;

  final double Function(
    Map<String, dynamic>,
  ) getExtraPrice;

  final String Function(
    double,
  ) formatOptionPrice;

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
          color:
              AppColors.textSecondary,
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
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 0.7,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.55,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              ...options.map(
                (option) {
                  final String name =
                      (option[
                                  'option_name'] ??
                              option['name'] ??
                              option['value'] ??
                              'Option')
                          .toString();

                  final double extra =
                      getExtraPrice(
                    option,
                  );

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
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
                                  FontWeight
                                      .w700,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Text(
                          formatOptionPrice(
                            extra,
                          ),
                          style:
                              TextStyle(
                            fontSize: 8,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color: extra >
                                    0
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
// PROMOTION APPLIED CARD
// =================================================================

class _PromotionAppliedCard
    extends StatelessWidget {
  final String promotionTitle;
  final double discountAmount;
  final int applications;

  const _PromotionAppliedCard({
    required this.promotionTitle,
    required this.discountAmount,
    required this.applications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success
              .withValues(
            alpha: 0.20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
              alpha: 0.018,
            ),
            blurRadius: 16,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =======================================================
          // PROMOTION ICON
          // =======================================================

          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.success
                  .withValues(
                alpha: 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 19,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: 12),

          // =======================================================
          // PROMOTION INFORMATION
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'PROMOTION APPLIED',
                  style: TextStyle(
                    fontSize: 6.5,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 0.9,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  promotionTitle,
                  style:
                      const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.2,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  applications > 1
                      ? 'Applied $applications times to this order.'
                      : 'Applied to this order.',
                  style: TextStyle(
                    fontSize: 8.5,
                    height: 1.35,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.68,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // =======================================================
          // SAVINGS
          // =======================================================

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                'YOU SAVED',
                style: TextStyle(
                  fontSize: 6,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 0.7,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.50,
                  ),
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                AppHelpers
                    .formatCurrency(
                  discountAmount,
                ),
                style:
                    const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.3,
                  color:
                      AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SUMMARY PRICE ROW
// =================================================================

class _SummaryPriceRow
    extends StatelessWidget {
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
              fontWeight:
                  FontWeight.w600,
              color: Colors.white
                  .withValues(
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
            fontWeight:
                FontWeight.w800,
            color:
                valueColor ??
                    Colors.white,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// LOADING
// =================================================================

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
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
      ),
      child: const Center(
        child: SizedBox(
          width: 21,
          height: 21,
          child:
              CircularProgressIndicator(
            strokeWidth: 2,
            color:
                AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// EMPTY
// =================================================================

class _EmptyOrderCard
    extends StatelessWidget {
  const _EmptyOrderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 26,
      ),
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
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  AppColors.background,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons
                  .receipt_long_outlined,
              size: 20,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'No item details found',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w900,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'The items for this order could not be loaded.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              height: 1.4,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}