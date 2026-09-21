import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

import 'seller_promo_banner.dart';

class SellerPromoCard extends StatelessWidget {
  final Map<String, dynamic> promotion;
  final String status;
  final VoidCallback onTap;

  const SellerPromoCard({
    super.key,
    required this.promotion,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title =
        promotion['title']?.toString().trim() ??
            'Untitled Promotion';

    final String description =
        promotion['description']
                ?.toString()
                .trim() ??
            '';

    final String? discountTag =
        _nullableString(
      promotion['discount_tag'],
    );

    final String? bannerUrl =
        _nullableString(
      promotion['banner_url'],
    );

    final String promotionType =
        promotion['promotion_type']
                ?.toString() ??
            'simple_discount';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: AppColors.border
                  .withValues(
                alpha: 0.25,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.035,
                ),
                blurRadius: 18,
                offset: const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // =============================================
                // BANNER
                // =============================================

                SellerPromoBanner(
                  bannerUrl: bannerUrl,
                  discountTag:
                      discountTag,
                  status: status,
                  promotionType:
                      promotionType,
                ),

                // =============================================
                // CONTENT
                // =============================================

                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    17,
                    16,
                    17,
                    17,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =========================================
                      // TITLE
                      // =========================================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.15,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    -0.35,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Container(
                            width: 34,
                            height: 34,
                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .background,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                11,
                              ),
                              border:
                                  Border.all(
                                color: AppColors
                                    .border
                                    .withValues(
                                  alpha:
                                      0.30,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 16,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                        ],
                      ),

                      // =========================================
                      // DESCRIPTION
                      // =========================================

                      if (description.isNotEmpty) ...[
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
                            fontSize: 10,
                            height: 1.45,
                            fontWeight:
                                FontWeight.w500,
                            color: AppColors
                                .textSecondary
                                .withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 15,
                      ),

                      // =========================================
                      // DEAL SUMMARY
                      // =========================================

                      _buildDealSummary(),

                      const SizedBox(
                        height: 14,
                      ),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border
                            .withValues(
                          alpha: 0.20,
                        ),
                      ),

                      const SizedBox(
                        height: 13,
                      ),

                      // =========================================
                      // TARGET + DATE
                      // =========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildTargetSummary(),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          _buildDate(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // DEAL SUMMARY
  // =============================================================

  Widget _buildDealSummary() {
    final String promotionType =
        promotion['promotion_type']
                ?.toString() ??
            '';

    final String discountType =
        promotion['discount_type']
                ?.toString() ??
            '';

    final num? value =
        promotion['discount_value']
            as num?;

    String valueText;

    if (promotionType ==
        'mix_and_match') {
      valueText =
          value == null
              ? 'Bundle deal'
              : '₱${_formatNumber(value)} bundle';
    } else {
      switch (discountType) {
        case 'percentage':
          valueText =
              value == null
                  ? 'Percentage discount'
                  : '${_formatNumber(value)}% off';
          break;

        case 'fixed_amount':
          valueText =
              value == null
                  ? 'Fixed discount'
                  : '₱${_formatNumber(value)} off';
          break;

        default:
          valueText =
              value == null
                  ? 'Discount'
                  : _formatNumber(value);
      }
    }

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            promotionType ==
                    'mix_and_match'
                ? Icons
                    .grid_view_rounded
                : Icons
                    .sell_outlined,
            size: 17,
            color:
                AppColors.textPrimary,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                promotionType ==
                        'mix_and_match'
                    ? 'MIX & MATCH'
                    : 'SIMPLE DISCOUNT',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors
                      .textSecondary
                      .withValues(
                    alpha: 0.58,
                  ),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                valueText,
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                  color: AppColors
                      .textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =============================================================
  // TARGET SUMMARY
  // =============================================================

  Widget _buildTargetSummary() {
    final String text =
        _targetSummary();

    return Row(
      children: [
        Icon(
          Icons
              .filter_alt_outlined,
          size: 14,
          color: AppColors
              .textSecondary
              .withValues(
            alpha: 0.70,
          ),
        ),

        const SizedBox(
          width: 6,
        ),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight:
                  FontWeight.w700,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.78,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _targetSummary() {
    final String promotionType =
        promotion['promotion_type']
                ?.toString() ??
            '';

    if (promotionType ==
        'mix_and_match') {
      final dynamic groups =
          promotion[
              'promotion_groups'];

      if (groups is List &&
          groups.isNotEmpty) {
        final List<String> names = [];

        for (final dynamic raw
            in groups) {
          if (raw is! Map) {
            continue;
          }

          final String name =
              raw['name']
                      ?.toString()
                      .trim() ??
                  '';

          final int quantity =
              (raw['required_quantity']
                          as num?)
                      ?.toInt() ??
                  1;

          if (name.isNotEmpty) {
            names.add(
              '$quantity× $name',
            );
          }
        }

        if (names.isNotEmpty) {
          return names.join(
            ' + ',
          );
        }
      }

      return 'Bundle selection';
    }

    final String appliesTo =
        promotion['applies_to']
                ?.toString() ??
            'store';

    if (appliesTo == 'store') {
      return 'Entire store';
    }

    final List<String>
        categoryNames = [];

    final dynamic categories =
        promotion[
            'promotion_categories'];

    if (categories is List) {
      for (final dynamic raw
          in categories) {
        if (raw is! Map) {
          continue;
        }

        final dynamic category =
            raw['category'];

        if (category is Map) {
          final String name =
              category['name']
                      ?.toString()
                      .trim() ??
                  '';

          if (name.isNotEmpty) {
            categoryNames.add(
              name,
            );
          }
        }
      }
    }

    final List<String>
        productNames = [];

    final dynamic products =
        promotion[
            'promotion_products'];

    if (products is List) {
      for (final dynamic raw
          in products) {
        if (raw is! Map) {
          continue;
        }

        final dynamic product =
            raw['product'];

        if (product is Map) {
          final String name =
              product['name']
                      ?.toString()
                      .trim() ??
                  '';

          if (name.isNotEmpty) {
            productNames.add(
              name,
            );
          }
        }
      }
    }

    final int categoryCount =
        categoryNames.length;

    final int productCount =
        productNames.length;

    if (categoryCount > 0 &&
        productCount > 0) {
      return '$categoryCount ${categoryCount == 1 ? 'category' : 'categories'}'
          ' + $productCount ${productCount == 1 ? 'product' : 'products'}';
    }

    if (categoryCount > 0) {
      if (categoryCount == 1) {
        return categoryNames.first;
      }

      return '$categoryCount categories';
    }

    if (productCount > 0) {
      if (productCount == 1) {
        return productNames.first;
      }

      return '$productCount products';
    }

    return 'Custom selection';
  }

  // =============================================================
  // DATE
  // =============================================================

  Widget _buildDate() {
    final DateTime? validUntil =
        DateTime.tryParse(
      promotion['valid_until']
              ?.toString() ??
          '',
    )?.toLocal();

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          Icons
              .calendar_today_outlined,
          size: 13,
          color: AppColors
              .textSecondary
              .withValues(
            alpha: 0.65,
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          validUntil == null
              ? 'No end date'
              : _formatDate(
                  validUntil,
                ),
          style: TextStyle(
            fontSize: 8,
            fontWeight:
                FontWeight.w700,
            color: AppColors
                .textSecondary
                .withValues(
              alpha: 0.72,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================

  String? _nullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final String result =
        value.toString().trim();

    if (result.isEmpty ||
        result.toLowerCase() ==
            'null') {
      return null;
    }

    return result;
  }

  String _formatNumber(
    num value,
  ) {
    if (value % 1 == 0) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );
  }

  String _formatDate(
    DateTime date,
  ) {
    const List<String> months = [
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}