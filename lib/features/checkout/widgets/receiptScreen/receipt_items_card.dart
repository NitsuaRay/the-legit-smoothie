import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'receipt_card.dart';
import 'receipt_order_item.dart';

class ReceiptItemsCard
    extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  final double originalSubtotal;
  final double discountAmount;
  final String? promotionTitle;

  const ReceiptItemsCard({
    super.key,
    required this.items,
    required this.originalSubtotal,
    required this.discountAmount,
    this.promotionTitle,
  });

  bool get _hasPromotion {
    return discountAmount > 0 &&
        promotionTitle != null &&
        promotionTitle!.trim().isNotEmpty;
  }

  double get _discountedSubtotal {
    return (originalSubtotal -
            discountAmount)
        .clamp(
          0.0,
          double.infinity,
        )
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return ReceiptCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Container(
                height: 1,
                color: AppColors.border
                    .withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            itemBuilder: (_, index) {
              return ReceiptOrderItem(
                item: items[index],
              );
            },
          ),

          if (_hasPromotion) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Container(
                height: 1,
                color: AppColors.border
                    .withValues(
                  alpha: 0.25,
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  // PROMOTION
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration:
                            BoxDecoration(
                          color: AppColors
                              .textPrimary
                              .withValues(
                            alpha: 0.06,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons
                              .local_offer_outlined,
                          size: 15,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'PROMOTION APPLIED',
                              style:
                                  TextStyle(
                                fontSize:
                                    6.5,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    0.8,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              promotionTitle!,
                              style:
                                  const TextStyle(
                                fontSize:
                                    10,
                                fontWeight:
                                    FontWeight
                                        .w800,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        '-₱${discountAmount.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w900,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // AFTER PROMOTION
                  Row(
                    children: [
                      Text(
                        'Items after promotion',
                        style:
                            TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight
                                  .w600,
                          color: AppColors
                              .textSecondary
                              .withValues(
                            alpha: 0.70,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '₱${_discountedSubtotal.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight
                                  .w900,
                          color: AppColors
                              .textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}