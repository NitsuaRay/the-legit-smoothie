import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'push_notification_service.dart';

class NotificationPermissionService {
  NotificationPermissionService._();

  static final NotificationPermissionService instance =
      NotificationPermissionService._();

  bool _promptBeingShown = false;

  // ============================================================
  // CHECK PERMISSION
  // ============================================================

  Future<void> checkAndPrompt({
    required BuildContext context,
    required String role,
  }) async {
    if (_promptBeingShown) {
      return;
    }

    try {
      final AuthorizationStatus status = await PushNotificationService.instance
          .getPermissionStatus();

      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // ALREADY ALLOWED
      // --------------------------------------------------------

      if (status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional) {
        return;
      }

      _promptBeingShown = true;

      await Future.delayed(const Duration(milliseconds: 700));

      if (!context.mounted) {
        return;
      }

      // --------------------------------------------------------
      // FIRST TIME
      // --------------------------------------------------------

      if (status == AuthorizationStatus.notDetermined) {
        await _showFirstTimePermissionDialog(context: context, role: role);

        return;
      }

      // --------------------------------------------------------
      // USER PREVIOUSLY DENIED PERMISSION
      // --------------------------------------------------------

      if (status == AuthorizationStatus.denied) {
        await _showPermissionDeniedDialog(context: context, role: role);

        return;
      }
    } catch (error) {
      debugPrint('Unable to check notification permission: $error');
    } finally {
      _promptBeingShown = false;
    }
  }

  // ============================================================
  // FIRST-TIME PERMISSION DIALOG
  // ============================================================

  Future<void> _showFirstTimePermissionDialog({
    required BuildContext context,
    required String role,
  }) async {
    final bool isSeller = role == 'seller';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =================================================
                // ICON
                // =================================================
                _buildIcon(icon: Icons.notifications_active_outlined),

                const SizedBox(height: 18),

                // =================================================
                // TITLE
                // =================================================
                Text(
                  isSeller
                      ? 'Never miss a new order'
                      : 'Stay updated on your order',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 9),

                // =================================================
                // DESCRIPTION
                // =================================================
                Text(
                  isSeller
                      ? 'Enable notifications so you can receive '
                            'new order alerts and important store updates.'
                      : 'Enable notifications to receive order '
                            'confirmations, status updates, and other '
                            'important updates from The Legit Smoothie.',
                  textAlign: TextAlign.center,
                  style: _descriptionStyle(),
                ),

                const SizedBox(height: 22),

                // =================================================
                // ENABLE NOTIFICATIONS
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      await PushNotificationService.instance
                          .requestNotificationPermission();
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Enable Notifications',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: _primaryButtonStyle(),
                  ),
                ),

                const SizedBox(height: 8),

                // =================================================
                // NOT NOW
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      'Not Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
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
  // PERMISSION DENIED DIALOG
  // ============================================================

  Future<void> _showPermissionDeniedDialog({
    required BuildContext context,
    required String role,
  }) async {
    final bool isSeller = role == 'seller';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =================================================
                // ICON
                // =================================================
                _buildIcon(icon: Icons.notifications_off_outlined),

                const SizedBox(height: 18),

                // =================================================
                // TITLE
                // =================================================
                const Text(
                  'Notifications are turned off',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 9),

                // =================================================
                // DESCRIPTION
                // =================================================
                Text(
                  isSeller
                      ? 'Notifications are currently disabled. '
                            'You may miss new order alerts and important '
                            'store updates.'
                      : 'Notifications are currently disabled. '
                            'You may miss order confirmations, status '
                            'updates, and other important alerts.',
                  textAlign: TextAlign.center,
                  style: _descriptionStyle(),
                ),

                const SizedBox(height: 22),

                // =================================================
                // OPEN SETTINGS
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      try {
                        const AndroidIntent intent = AndroidIntent(
                          action: 'android.settings.APP_NOTIFICATION_SETTINGS',
                          arguments: <String, dynamic>{
                            'android.provider.extra.APP_PACKAGE':
                                'com.thelegitsmoothie.the_legit_smoothie',
                          },
                        );

                        await intent.launch();
                      } catch (error) {
                        debugPrint(
                          'Unable to open notification settings: $error',
                        );
                      }
                    },
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text(
                      'Open Settings',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: _primaryButtonStyle(),
                  ),
                ),

                const SizedBox(height: 8),

                // =================================================
                // NOT NOW
                // =================================================
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      'Not Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
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
  // DIALOG ICON
  // ============================================================

  Widget _buildIcon({required IconData icon}) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: AppColors.primary),
    );
  }

  // ============================================================
  // DIALOG DECORATION
  // ============================================================

  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 30,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION STYLE
  // ============================================================

  TextStyle _descriptionStyle() {
    return TextStyle(
      fontSize: 12,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary.withValues(alpha: 0.78),
    );
  }

  // ============================================================
  // PRIMARY BUTTON STYLE
  // ============================================================

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
