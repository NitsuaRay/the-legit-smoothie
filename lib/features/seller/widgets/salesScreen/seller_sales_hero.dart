import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerSalesHero extends StatelessWidget {
  final String salesValue;
  final int completedOrders;

  const SellerSalesHero({
    super.key,
    required this.salesValue,
    required this.completedOrders,
  });

  // =============================================================
  // DATE
  // =============================================================

  String get _formattedDate {
    final DateTime now = DateTime.now();

    const List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} '
        '${now.day}, ${now.year}';
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.12,
            ),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // ===================================================
            // DECORATIVE BACKGROUND
            // ===================================================

            Positioned(
              top: -65,
              right: -45,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.035,
                  ),
                ),
              ),
            ),

            Positioned(
              top: -5,
              right: 40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.025,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -70,
              left: -45,
              child: Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.025,
                  ),
                ),
              ),
            ),

            // ===================================================
            // CONTENT
            // ===================================================

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============================================
                  // HEADER
                  // =============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: 0.09,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .account_balance_wallet_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'TODAY\'S SALES',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing:
                                    1.15,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              _formattedDate,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight.w600,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.76,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // ===========================================
                      // LIVE BADGE
                      // ===========================================

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: 0.07,
                            ),
                          ),
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
                                color: AppColors
                                    .success,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),

                            const SizedBox(
                              width: 6,
                            ),

                            Text(
                              'TODAY',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing:
                                    0.65,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // =============================================
                  // REVENUE LABEL
                  // =============================================

                  Text(
                    'TOTAL REVENUE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 1,
                      color: Colors.white
                          .withValues(
                        alpha: 0.42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =============================================
                  // SALES VALUE
                  // =============================================

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        Alignment.centerLeft,
                    child: Text(
                      salesValue,
                      style: const TextStyle(
                        fontSize: 36,
                        height: 1,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: -1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    completedOrders == 0
                        ? 'No revenue recorded from completed orders yet.'
                        : 'Revenue from completed orders today.',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      fontWeight:
                          FontWeight.w500,
                      color: Colors.white
                          .withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =============================================
                  // DIVIDER
                  // =============================================

                  Container(
                    height: 1,
                    color: Colors.white
                        .withValues(
                      alpha: 0.07,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =============================================
                  // COMPLETED ORDERS
                  // =============================================

                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.07,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .check_circle_outline_rounded,
                          size: 16,
                          color: Colors.white
                              .withValues(
                            alpha: 0.80,
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
                              'COMPLETED ORDERS',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing:
                                    0.75,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.42,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              completedOrders == 0
                                  ? 'No completed orders today'
                                  : '$completedOrders '
                                      '${completedOrders == 1 ? 'order' : 'orders'} completed today',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w600,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ===========================================
                      // COUNT
                      // ===========================================

                      Container(
                        constraints:
                            const BoxConstraints(
                          minWidth: 40,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            11,
                          ),
                          border: Border.all(
                            color: Colors.white
                                .withValues(
                              alpha: 0.07,
                            ),
                          ),
                        ),
                        child: Text(
                          '$completedOrders',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 13,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}