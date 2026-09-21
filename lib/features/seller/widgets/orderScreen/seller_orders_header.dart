import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SellerOrdersHeader extends StatelessWidget {
  final int pendingOrderCount;

  const SellerOrdersHeader({
    super.key,
    required this.pendingOrderCount,
  });

  // ============================================================
  // ORDER REMINDER
  // ============================================================

  void _showOrderReminder(
    BuildContext context,
  ) {
    final bool hasPendingOrders =
        pendingOrderCount > 0;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.35,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =================================================
                // HANDLE
                // =================================================

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // ICON
                // =================================================

                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.border.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasPendingOrders
                          ? AppColors.textPrimary
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      hasPendingOrders
                          ? Icons
                              .notifications_active_outlined
                          : Icons
                              .notifications_none_rounded,
                      size: 23,
                      color: hasPendingOrders
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =================================================
                // LABEL
                // =================================================

                Text(
                  hasPendingOrders
                      ? 'ORDER REMINDER'
                      : 'ORDER UPDATES',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.15,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.60,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                // =================================================
                // TITLE
                // =================================================

                Text(
                  hasPendingOrders
                      ? '$pendingOrderCount ${pendingOrderCount == 1 ? 'order needs' : 'orders need'} attention'
                      : 'You\'re all caught up',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // =================================================
                // DESCRIPTION
                // =================================================

                Text(
                  hasPendingOrders
                      ? pendingOrderCount == 1
                          ? 'You have a new pending order waiting to be reviewed.'
                          : 'You have $pendingOrderCount pending orders waiting to be reviewed.'
                      : 'There are no new pending orders that require your attention right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.75,
                    ),
                  ),
                ),

                // =================================================
                // PENDING SUMMARY
                // =================================================

                if (hasPendingOrders) ...[
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border.withValues(
                          alpha: 0.30,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(11),
                            border: Border.all(
                              color: AppColors.border
                                  .withValues(
                                alpha: 0.30,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 17,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending orders',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w800,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'Waiting for your review and confirmation.',
                                style: TextStyle(
                                  fontSize: 9,
                                  height: 1.35,
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          constraints:
                              const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.textPrimary,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              pendingOrderCount > 99
                                  ? '99+'
                                  : '$pendingOrderCount',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight:
                                    FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // =================================================
                // DISMISS
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        sheetContext,
                      ).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        18,
        AppConstants.defaultPadding,
        18,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          // =====================================================
          // SECTION ICON
          // =====================================================

          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.45,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.20,
                  ),
                ),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 21,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 13),

          // =====================================================
          // TITLE
          // =====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER MANAGEMENT',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.15,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 23,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.65,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Manage and fulfill customer orders',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // =====================================================
          // REMINDER BUTTON
          // =====================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  _showOrderReminder(context),
              borderRadius:
                  BorderRadius.circular(14),
              child: Ink(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        AppColors.border.withValues(
                      alpha: 0.45,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(
                        alpha: 0.025,
                      ),
                      blurRadius: 12,
                      offset:
                          const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        pendingOrderCount > 0
                            ? Icons
                                .notifications_active_outlined
                            : Icons
                                .notifications_none_rounded,
                        size: 20,
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    if (pendingOrderCount > 0)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          constraints:
                              const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: AppColors
                                .textPrimary,
                            borderRadius:
                                BorderRadius
                                    .circular(20),
                            border: Border.all(
                              color: AppColors
                                  .background,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              pendingOrderCount > 99
                                  ? '99+'
                                  : '$pendingOrderCount',
                              style:
                                  const TextStyle(
                                fontSize: 7.5,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
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