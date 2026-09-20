import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class OrderSummary extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> itemsFuture;

  // New
  final String orderType;
  final double totalPrice;

  // Same delivery fee used during checkout
  static const double deliveryFeeAmount = 45.00;

  const OrderSummary({
    super.key,
    required this.itemsFuture,
    required this.orderType,
    required this.totalPrice,
  });

  // ============================================================
  // PARSE SELECTED OPTIONS
  // ============================================================
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
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }

    if (rawOptions is String &&
        rawOptions.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawOptions);

        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      } catch (_) {
        return [];
      }
    }

    return [];
  }

  // ============================================================
  // EXTRA PRICE
  // ============================================================
  double _getExtraPrice(
    Map<String, dynamic> option,
  ) {
    final value = option['extra_price'];

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

  // ============================================================
  // PRICE LABEL
  // ============================================================
  String _formatOptionPrice(double price) {
    if (price <= 0) {
      return 'Included';
    }

    return '+${AppHelpers.formatCurrency(price)}';
  }

  // ============================================================
  // OPTION ICON
  // ============================================================
  IconData _getGroupIcon(String group) {
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

  // ============================================================
  // GROUP OPTIONS
  // ============================================================
  Map<String, List<Map<String, dynamic>>> _groupOptions(
    List<Map<String, dynamic>> options,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final option in options) {
      final String group =
          option['group']?.toString().trim().isNotEmpty == true
              ? option['group'].toString()
              : 'Options';

      grouped.putIfAbsent(group, () => []).add(option);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDelivery =
        orderType.toLowerCase() == 'delivery';

    final double deliveryFee =
        isDelivery ? deliveryFeeAmount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ========================================================
        // SECTION HEADER
        // ========================================================
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Review your items, customizations, and total.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: AppColors.textSecondary.withValues(
              alpha: 0.85,
            ),
          ),
        ),

        const SizedBox(height: 16),

        FutureBuilder<List<Map<String, dynamic>>>(
          future: itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No item details found',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final items = snapshot.data!;

            // ====================================================
            // CALCULATE SUBTOTAL FROM ITEMS
            // ====================================================
            double itemsSubtotal = 0;

            for (final item in items) {
              itemsSubtotal +=
                  ((item['total_price'] ?? 0) as num)
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
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.border.withValues(
                        alpha: 0.55,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.025,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      child: Divider(
                        height: 1,
                        color: AppColors.border,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];

                      final String itemName =
                          (item['product_name'] ?? 'Item')
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
                          item['customizations'];

                      final options =
                          _parseSelectedOptions(
                        rawOptions,
                      );

                      final groupedOptions =
                          _groupOptions(options);

                      double optionsTotal = 0;

                      for (final option in options) {
                        optionsTotal +=
                            _getExtraPrice(option);
                      }

                      final double unitTotal =
                          quantity > 0
                              ? lineTotal / quantity
                              : lineTotal;

                      final double baseUnitPrice =
                          (unitTotal - optionsTotal)
                              .clamp(0, double.infinity);

                      final double baseLinePrice =
                          baseUnitPrice * quantity;

                      final double optionLineTotal =
                          optionsTotal * quantity;

                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ========================================
                          // ITEM HEADER
                          // ========================================
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 9,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient:
                                      LinearGradient(
                                    colors: [
                                      AppColors.primary
                                          .withValues(
                                        alpha: 0.13,
                                      ),
                                      AppColors.primary
                                          .withValues(
                                        alpha: 0.06,
                                      ),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    9,
                                  ),
                                ),
                                child: Text(
                                  '${quantity}x',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        AppColors.primary,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      style:
                                          const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w800,
                                        color: AppColors
                                            .textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      quantity > 1
                                          ? '$quantity items'
                                          : '1 item',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors
                                            .textSecondary
                                            .withValues(
                                          alpha: 0.8,
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
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w900,
                                  color:
                                      AppColors.primary,
                                ),
                              ),
                            ],
                          ),

                          // ========================================
                          // CUSTOMIZATIONS
                          // ========================================
                          if (groupedOptions
                              .isNotEmpty) ...[
                            const SizedBox(height: 16),

                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: AppColors.background
                                    .withValues(
                                  alpha: 0.48,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  16,
                                ),
                                border: Border.all(
                                  color: AppColors.border
                                      .withValues(
                                    alpha: 0.45,
                                  ),
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
                                        width: 28,
                                        height: 28,
                                        decoration:
                                            BoxDecoration(
                                          color: AppColors
                                              .primary
                                              .withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons
                                              .tune_rounded,
                                          size: 15,
                                          color: AppColors
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const Text(
                                        'Your Customizations',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                          letterSpacing:
                                              0.3,
                                          color: AppColors
                                              .textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  ...groupedOptions
                                      .entries
                                      .map(
                                    (entry) {
                                      final String group =
                                          entry.key;

                                      final List<
                                          Map<String,
                                              dynamic>>
                                          groupOptions =
                                          entry.value;

                                      return Padding(
                                        padding:
                                            const EdgeInsets
                                                .only(
                                          bottom: 12,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Icon(
                                              _getGroupIcon(
                                                group,
                                              ),
                                              size: 15,
                                              color: AppColors
                                                  .textSecondary,
                                            ),

                                            const SizedBox(
                                              width: 8,
                                            ),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    group
                                                        .toUpperCase(),
                                                    style:
                                                        TextStyle(
                                                      fontSize:
                                                          9,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing:
                                                          0.8,
                                                      color: AppColors
                                                          .textSecondary
                                                          .withValues(
                                                        alpha:
                                                            0.8,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height: 4,
                                                  ),

                                                  ...groupOptions
                                                      .map(
                                                    (option) {
                                                      final String
                                                          optionName =
                                                          option[
                                                                      'name']
                                                                  ?.toString() ??
                                                              'Option';

                                                      final double
                                                          extraPrice =
                                                          _getExtraPrice(
                                                        option,
                                                      );

                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                          bottom:
                                                              3,
                                                        ),
                                                        child:
                                                            Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  Text(
                                                                optionName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize:
                                                                      12,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                  color:
                                                                      AppColors.textPrimary,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              _formatOptionPrice(
                                                                extraPrice,
                                                              ),
                                                              style:
                                                                  TextStyle(
                                                                fontSize:
                                                                    11,
                                                                fontWeight:
                                                                    FontWeight.w700,
                                                                color: extraPrice >
                                                                        0
                                                                    ? AppColors.primary
                                                                    : AppColors.textSecondary,
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
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // ========================================
                          // ITEM PRICE BREAKDOWN
                          // ========================================
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(
                              13,
                              11,
                              13,
                              11,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(
                                alpha: 0.035,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                            child: Column(
                              children: [
                                _PriceRow(
                                  label: quantity > 1
                                      ? 'Base Price × $quantity'
                                      : 'Base Price',
                                  value: AppHelpers
                                      .formatCurrency(
                                    baseLinePrice,
                                  ),
                                ),

                                if (optionLineTotal > 0) ...[
                                  const SizedBox(height: 6),
                                  _PriceRow(
                                    label:
                                        'Customizations × $quantity',
                                    value:
                                        '+${AppHelpers.formatCurrency(optionLineTotal)}',
                                    valueColor:
                                        AppColors.primary,
                                  ),
                                ],

                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Divider(
                                    height: 1,
                                    color:
                                        AppColors.border,
                                  ),
                                ),

                                _PriceRow(
                                  label: 'Item Total',
                                  value: AppHelpers
                                      .formatCurrency(
                                    lineTotal,
                                  ),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // FINAL ORDER TOTAL
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Subtotal
                      _SummaryPriceRow(
                        label: 'Subtotal',
                        value:
                            AppHelpers.formatCurrency(
                          itemsSubtotal,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Delivery Fee / Pickup
                      if (isDelivery)
                        _SummaryPriceRow(
                          label: 'Delivery Fee',
                          value:
                              AppHelpers.formatCurrency(
                            deliveryFee,
                          ),
                          valueColor:
                              AppColors.textPrimary,
                        )
                      else
                        _SummaryPriceRow(
                          label: 'Store Pickup',
                          value: 'FREE',
                          valueColor:
                              AppColors.success,
                        ),

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Divider(
                          height: 1,
                          color: AppColors.border,
                        ),
                      ),

                      // Grand Total
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w800,
                                    color: AppColors
                                        .textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Final order total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppHelpers.formatCurrency(
                              totalPrice,
                            ),
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -0.5,
                              color:
                                  AppColors.primary,
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

// ============================================================
// ITEM PRICE ROW
// ============================================================
class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 12.5 : 11,
              fontWeight: isTotal
                  ? FontWeight.w800
                  : FontWeight.w500,
              color: isTotal
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 14 : 11,
            fontWeight: isTotal
                ? FontWeight.w900
                : FontWeight.w700,
            color: valueColor ??
                (isTotal
                    ? AppColors.textPrimary
                    : AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FINAL SUMMARY PRICE ROW
// ============================================================
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color:
                valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}