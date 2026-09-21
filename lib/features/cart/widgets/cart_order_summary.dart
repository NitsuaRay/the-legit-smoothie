import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';

class CartOrderSummary
    extends StatelessWidget {
  final int totalCount;
  final double subtotal;
  final VoidCallback onCheckout;

  const CartOrderSummary({
    super.key,
    required this.totalCount,
    required this.subtotal,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        16,
        AppConstants.defaultPadding,
        14 +
            MediaQuery.of(context)
                .padding
                .bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border
                .withValues(alpha: 0.28),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.50),
                ),
              ),

              const Spacer(),

              Text(
                '$totalCount '
                '${totalCount == 1 ? 'ITEM' : 'ITEMS'}',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.50),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Delivery fee is calculated at checkout',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight:
                            FontWeight.w500,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.52,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                AppHelpers.formatCurrency(
                  subtotal,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.textPrimary,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shadowColor:
                    Colors.transparent,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Checkout',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: -0.1,
                    ),
                  ),

                  SizedBox(width: 9),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}