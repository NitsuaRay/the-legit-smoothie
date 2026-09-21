import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

import 'customer_promo_badge.dart';
import 'customer_promo_banner.dart';

class CustomerPromoCard
    extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const CustomerPromoCard({
    super.key,
    required this.promotion,
  });

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  DateTime? _date(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    )?.toLocal();
  }

  bool get _upcoming {
    final DateTime? startsAt =
        _date(promotion['starts_at']);

    if (startsAt == null) {
      return false;
    }

    return DateTime.now()
        .isBefore(startsAt);
  }

  String get _dealLabel {
    final String type =
        promotion['promotion_type']
                ?.toString() ??
            '';

    if (type == 'mix_and_match') {
      final double value =
          _toDouble(
        promotion['discount_value'],
      );

      if (value > 0) {
        return 'Mix & Match • ₱${_cleanNumber(value)}';
      }

      return 'Mix & Match';
    }

    final String discountType =
        promotion['discount_type']
                ?.toString() ??
            '';

    final double value =
        _toDouble(
      promotion['discount_value'],
    );

    if (discountType ==
        'percentage') {
      return '${_cleanNumber(value)}% OFF';
    }

    if (discountType ==
            'fixed' ||
        discountType ==
            'fixed_amount') {
      return 'SAVE ₱${_cleanNumber(value)}';
    }

    return promotion['discount_tag']
            ?.toString() ??
        'Special offer';
  }

  String _cleanNumber(double value) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(2);
  }

  String get _targetLabel {
    final String appliesTo =
        promotion['applies_to']
                ?.toString()
                .toLowerCase() ??
            'store';

    if (appliesTo == 'store') {
      return 'Entire store';
    }

    final List<String> categories = [];
    final List<String> products = [];

    final dynamic categoryRows =
        promotion[
            'promotion_categories'];

    if (categoryRows is List) {
      for (final dynamic row
          in categoryRows) {
        if (row is! Map) continue;

        final dynamic category =
            row['categories'];

        if (category is Map) {
          final String name =
              category['name']
                      ?.toString()
                      .trim() ??
                  '';

          if (name.isNotEmpty) {
            categories.add(name);
          }
        }
      }
    }

    final dynamic productRows =
        promotion[
            'promotion_products'];

    if (productRows is List) {
      for (final dynamic row
          in productRows) {
        if (row is! Map) continue;

        final dynamic product =
            row['products'];

        if (product is Map) {
          final String name =
              product['name']
                      ?.toString()
                      .trim() ??
                  '';

          if (name.isNotEmpty) {
            products.add(name);
          }
        }
      }
    }

    if (categories.isNotEmpty &&
        products.isNotEmpty) {
      return '${categories.length} categories + '
          '${products.length} products';
    }

    if (categories.isNotEmpty) {
      if (categories.length <= 2) {
        return categories.join(', ');
      }

      return '${categories.length} categories';
    }

    if (products.isNotEmpty) {
      if (products.length == 1) {
        return products.first;
      }

      return '${products.length} products';
    }

    if (promotion['promotion_type'] ==
        'mix_and_match') {
      return 'Selected combinations';
    }

    return 'Selected items';
  }

  String get _requirementLabel {
    final double minimumOrder =
        _toDouble(
      promotion[
          'minimum_order_amount'],
    );

    final int minimumQuantity =
        _toInt(
      promotion['minimum_quantity'],
    );

    if (minimumOrder > 0) {
      return 'Min. ₱${_cleanNumber(minimumOrder)}';
    }

    if (minimumQuantity > 0) {
      return 'Min. $minimumQuantity items';
    }

    return 'No minimum';
  }

  String get _dateLabel {
    final DateTime? startsAt =
        _date(promotion['starts_at']);

    final DateTime? validUntil =
        _date(
      promotion['valid_until'],
    );

    if (_upcoming &&
        startsAt != null) {
      return 'Starts ${_formatDate(startsAt)}';
    }

    if (validUntil != null) {
      return 'Until ${_formatDate(validUntil)}';
    }

    return 'Limited time';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        promotion['title']
                ?.toString()
                .trim() ??
            'Special offer';

    final String description =
        promotion['description']
                ?.toString()
                .trim() ??
            '';

    final String promotionType =
        promotion['promotion_type']
                ?.toString()
                .trim() ??
            'simple_discount';

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(22),
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
              alpha: 0.025,
            ),
            blurRadius: 20,
            offset:
                const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CustomerPromoBanner(
            bannerUrl:
                promotion['banner_url']
                    ?.toString(),
            discountTag:
                promotion[
                        'discount_tag']
                    ?.toString(),
            upcoming: _upcoming,
            promotionType:
                promotionType,
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              7,
              14,
              7,
              8,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ================================================
                // DEAL
                // ================================================

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dealLabel
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          fontSize: 7,
                          fontWeight:
                              FontWeight.w900,
                          letterSpacing: 1,
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ),

                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(
                        color: _upcoming
                            ? AppColors
                                .textSecondary
                            : AppColors
                                .success,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Text(
                      _upcoming
                          ? 'COMING SOON'
                          : 'AVAILABLE',
                      style:
                          TextStyle(
                        fontSize: 6.5,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            0.6,
                        color: _upcoming
                            ? AppColors
                                .textSecondary
                            : AppColors
                                .success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    height: 1.15,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.35,
                    color: AppColors
                        .textPrimary,
                  ),
                ),

                if (description
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 7,
                  ),

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.45,
                      fontWeight:
                          FontWeight.w500,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.74,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // ================================================
                // META
                // ================================================

                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    CustomerPromoBadge(
                      icon: Icons
                          .shopping_bag_outlined,
                      text:
                          _targetLabel,
                    ),
                    CustomerPromoBadge(
                      icon: Icons
                          .payments_outlined,
                      text:
                          _requirementLabel,
                    ),
                    CustomerPromoBadge(
                      icon: Icons
                          .schedule_outlined,
                      text:
                          _dateLabel,
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                Divider(
                  height: 1,
                  color: AppColors.border
                      .withValues(
                    alpha: 0.35,
                  ),
                ),

                const SizedBox(height: 11),

                // ================================================
                // FOOTER
                // ================================================

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 31,
                            height: 31,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .background,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                9,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons
                                  .local_offer_outlined,
                              size: 14,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child: Text(
                              _upcoming
                                  ? 'Available soon'
                                  : 'Applied automatically when eligible',
                              style:
                                  TextStyle(
                                fontSize: 8,
                                height: 1.3,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha:
                                      0.68,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!_upcoming)
                      Container(
                        width: 34,
                        height: 34,
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .textPrimary,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 15,
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
      ),
    );
  }
}