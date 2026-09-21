import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerDashboardHeader extends StatelessWidget {
  final String sellerName;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const SellerDashboardHeader({
    super.key,
    required this.sellerName,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  // =============================================================
  // HELPERS
  // =============================================================

  String _firstName(String name) {
    final String cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      return 'Seller';
    }

    return cleanedName.split(' ').first;
  }

  Future<void> _showNotifications(
    BuildContext context,
  ) async {
    final bool hasPendingOrders =
        notificationCount > 0;

    final bool? shouldOpenOrders =
        await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              20,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.border.withValues(
                  alpha: 0.30,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.08,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =============================================
                // HANDLE
                // =============================================

                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(
                      alpha: 0.65,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // =============================================
                // ICON
                // =============================================

                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 27,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      if (hasPendingOrders)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

                // =============================================
                // EYEBROW
                // =============================================

                Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary
                        .withValues(alpha: 0.52),
                  ),
                ),

                const SizedBox(height: 8),

                // =============================================
                // TITLE
                // =============================================

                Text(
                  hasPendingOrders
                      ? 'Orders need your attention'
                      : 'You\'re all caught up',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.65,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 9),

                // =============================================
                // DESCRIPTION
                // =============================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Text(
                    hasPendingOrders
                        ? notificationCount == 1
                            ? 'You have 1 pending order waiting to be reviewed.'
                            : 'You have $notificationCount pending orders waiting to be reviewed.'
                        : 'There are no pending orders waiting for your attention right now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.72),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =============================================
                // SUMMARY
                // =============================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.20,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PENDING ORDERS',
                              style: TextStyle(
                                fontSize: 7,
                                height: 1,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                      alpha: 0.52,
                                    ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              hasPendingOrders
                                  ? '$notificationCount ${notificationCount == 1 ? 'order' : 'orders'} waiting'
                                  : 'Nothing waiting',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight:
                                    FontWeight.w800,
                                color:
                                    AppColors.textPrimary,
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
                          color: hasPendingOrders
                              ? AppColors.textPrimary
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(30),
                          border: Border.all(
                            color: hasPendingOrders
                                ? AppColors.textPrimary
                                : AppColors.border
                                    .withValues(
                                    alpha: 0.30,
                                  ),
                          ),
                        ),
                        child: Text(
                          hasPendingOrders
                              ? 'ACTION'
                              : 'CLEAR',
                          style: TextStyle(
                            fontSize: 7,
                            height: 1,
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 0.6,
                            color: hasPendingOrders
                                ? Colors.white
                                : AppColors
                                    .textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =============================================
                // PRIMARY ACTION
                // =============================================

                if (hasPendingOrders)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(sheetContext)
                            .pop(true);
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
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 17,
                          ),

                          SizedBox(width: 8),

                          Text(
                            'View Orders',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          SizedBox(width: 7),

                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                if (hasPendingOrders)
                  const SizedBox(height: 5),

                // =============================================
                // CLOSE
                // =============================================

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext)
                          .pop(false);
                    },
                    child: Text(
                      hasPendingOrders
                          ? 'Maybe later'
                          : 'Got it',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            AppColors.textSecondary,
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

    if (shouldOpenOrders == true) {
      onNotificationTap?.call();
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final String firstName =
        _firstName(sellerName);

    return Row(
      children: [
        // =======================================================
        // LOGO
        // =======================================================

        Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.45,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logoSmoothie.png',
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.local_drink_outlined,
                  size: 25,
                  color: AppColors.textPrimary,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 13),

        // =======================================================
        // STORE IDENTITY
        // =======================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'THE LEGIT SMOOTHIE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.15,
                  color: AppColors.textSecondary
                      .withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Hi, $firstName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.55,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration:
                        const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Flexible(
                    child: Text(
                      'Seller dashboard',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1,
                        fontWeight:
                            FontWeight.w600,
                        color: AppColors
                            .textSecondary
                            .withValues(
                              alpha: 0.68,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // =======================================================
        // NOTIFICATIONS
        // =======================================================

        _NotificationButton(
          count: notificationCount,
          onTap: () {
            _showNotifications(context);
          },
        ),
      ],
    );
  }
}

// =================================================================
// NOTIFICATION BUTTON
// =================================================================

class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationButton({
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNotifications = count > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: hasNotifications
                ? AppColors.textPrimary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasNotifications
                  ? AppColors.textPrimary
                  : AppColors.border.withValues(
                      alpha: 0.45,
                    ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: hasNotifications
                      ? 0.08
                      : 0.025,
                ),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  hasNotifications
                      ? Icons.notifications_rounded
                      : Icons
                          .notifications_none_rounded,
                  size: 20,
                  color: hasNotifications
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),

              if (hasNotifications)
                Positioned(
                  right: -4,
                  top: -5,
                  child: Container(
                    constraints:
                        const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    decoration: BoxDecoration(
                      // Black notification badge,
                      // matching seller Orders UI.
                      color: AppColors.textPrimary,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 6,
                          offset:
                              const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count > 99
                            ? '99+'
                            : '$count',
                        style: const TextStyle(
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
    );
  }
}