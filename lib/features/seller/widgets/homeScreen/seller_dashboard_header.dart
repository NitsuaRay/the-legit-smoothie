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

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final String firstName = _firstName(sellerName);

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
            border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logoSmoothie.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
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
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 5),

                  Flexible(
                    child: Text(
                      'Seller dashboard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.68),
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
        _NotificationButton(count: notificationCount, onTap: onNotificationTap),
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

  const _NotificationButton({required this.count, this.onTap});

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
            color: hasNotifications ? AppColors.textPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasNotifications
                  ? AppColors.textPrimary
                  : AppColors.border.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: hasNotifications ? 0.08 : 0.025,
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
                      : Icons.notifications_none_rounded,
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
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      // Black notification badge,
                      // matching seller Orders UI.
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          fontSize: 7.5,
                          height: 1,
                          fontWeight: FontWeight.w900,
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
