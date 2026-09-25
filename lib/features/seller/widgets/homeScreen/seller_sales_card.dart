import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesCard extends StatelessWidget {
  final String value;
  final int completedOrders;
  final VoidCallback? onViewSales;

  const SellerSalesCard({
    super.key,
    required this.value,
    this.completedOrders = 0,
    this.onViewSales,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // TOP
          // =======================================================

          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: 0.08,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S SALES',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1.1,
                        color: Colors.white
                            .withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Completed order revenue',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight:
                            FontWeight.w500,
                        color: Colors.white
                            .withValues(
                          alpha: 0.68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          const BoxDecoration(
                        color:
                            AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 7.5,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.7,
                        color: Colors.white
                            .withValues(
                          alpha: 0.80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =======================================================
          // SALES VALUE
          // =======================================================

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 32,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.25,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            completedOrders == 0
                ? 'No completed orders yet today'
                : '$completedOrders completed '
                    '${completedOrders == 1 ? 'order' : 'orders'} '
                    'today',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(
                alpha: 0.60,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =======================================================
          // FOOTER / VIEW SALES
          // =======================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewSales,
              borderRadius:
                  BorderRadius.circular(13),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.065,
                  ),
                  borderRadius:
                      BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white
                        .withValues(
                      alpha: 0.07,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 16,
                      color: Colors.white
                          .withValues(
                        alpha: 0.72,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        'View sales history',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                          color: Colors.white
                              .withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                    ),

                    Text(
                      'VIEW SALES',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.65,
                        color: Colors.white
                            .withValues(
                          alpha: 0.90,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Icon(
                      Icons
                          .arrow_forward_ios_rounded,
                      size: 11,
                      color: Colors.white
                          .withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}