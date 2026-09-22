import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/models/app_update_info.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  /// Called when the customer presses UPDATE.
  final VoidCallback onUpdate;

  /// Called when an optional update is dismissed.
  final VoidCallback? onLater;

  /// True while we are opening/downloading the update.
  final bool isUpdating;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onUpdate,
    this.onLater,
    this.isUpdating = false,
  });

  // ============================================================
  // STATE
  // ============================================================

  bool get _isRequired {
    return updateInfo.isRequired;
  }

  String get _eyebrow {
    return _isRequired
        ? 'UPDATE REQUIRED'
        : 'UPDATE AVAILABLE';
  }

  String get _title {
    final String customTitle =
        updateInfo.updateTitle.trim();

    if (customTitle.isNotEmpty) {
      return customTitle;
    }

    return _isRequired
        ? 'Update required'
        : 'A new version is ready';
  }

  String get _message {
    final String customMessage =
        updateInfo.updateMessage.trim();

    if (customMessage.isNotEmpty) {
      return customMessage;
    }

    if (_isRequired) {
      return 'This version of The Legit Smoothie is no longer supported. '
          'Please update the app to continue.';
    }

    return 'A newer version of The Legit Smoothie is available '
        'with the latest improvements and fixes.';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Required updates cannot be bypassed using Android back.
      canPop: !_isRequired && !isUpdating,

      child: Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 24,
        ),
        backgroundColor: Colors.transparent,

        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.32,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.10,
                ),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // TOP AREA
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    22,
                    22,
                    0,
                  ),

                  child: Column(
                    children: [
                      // ==============================================
                      // OPTIONAL CLOSE BUTTON
                      // ==============================================

                      if (!_isRequired)
                        Align(
                          alignment: Alignment.centerRight,
                          child: _CloseButton(
                            enabled: !isUpdating,
                            onTap: () {
                              if (isUpdating) {
                                return;
                              }

                              if (onLater != null) {
                                onLater!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        )
                      else
                        const SizedBox(
                          height: 34,
                        ),

                      const SizedBox(height: 6),

                      // ==============================================
                      // ICON
                      // ==============================================

                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius:
                              BorderRadius.circular(21),
                        ),
                        child: Icon(
                          _isRequired
                              ? Icons.system_update_alt_rounded
                              : Icons
                                  .new_releases_outlined,
                          size: 29,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==============================================
                      // EYEBROW
                      // ==============================================

                      Text(
                        _eyebrow,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.25,
                          color: AppColors.textSecondary
                              .withValues(
                            alpha: 0.58,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ==============================================
                      // TITLE
                      // ==============================================

                      Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.65,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 9),

                      // ==============================================
                      // VERSION
                      // ==============================================

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.border
                                .withValues(
                              alpha: 0.28,
                            ),
                          ),
                        ),
                        child: Text(
                          'VERSION ${updateInfo.latestVersion}',
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==============================================
                      // MESSAGE
                      // ==============================================

                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary
                              .withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==============================================
                      // VERSION INFORMATION
                      // ==============================================

                      _VersionInformation(
                        currentVersion:
                            updateInfo.currentVersion,
                        latestVersion:
                            updateInfo.latestVersion,
                        requiredUpdate: _isRequired,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // BOTTOM ACTION AREA
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    22,
                    18,
                    22,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background
                        .withValues(
                      alpha: 0.72,
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border
                            .withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // ==============================================
                      // UPDATE BUTTON
                      // ==============================================

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed:
                              isUpdating ? null : onUpdate,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                AppColors.textPrimary,
                            disabledBackgroundColor:
                                AppColors.textPrimary
                                    .withValues(
                              alpha: 0.70,
                            ),
                            foregroundColor:
                                Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            child: isUpdating
                                ? const Row(
                                    key: ValueKey(
                                      'updating',
                                    ),
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      SizedBox(
                                        width: 17,
                                        height: 17,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color:
                                              Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'OPENING UPDATE...',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                          letterSpacing:
                                              0.8,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    key: const ValueKey(
                                      'update',
                                    ),
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      const Icon(
                                        Icons
                                            .system_update_alt_rounded,
                                        size: 17,
                                      ),
                                      const SizedBox(
                                        width: 9,
                                      ),
                                      Text(
                                        _isRequired
                                            ? 'UPDATE APP'
                                            : 'UPDATE NOW',
                                        style:
                                            const TextStyle(
                                          fontSize: 9,
                                          fontWeight:
                                              FontWeight
                                                  .w900,
                                          letterSpacing:
                                              0.9,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      // ==============================================
                      // MAYBE LATER
                      // ==============================================

                      if (!_isRequired) ...[
                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: isUpdating
                              ? null
                              : () {
                                  if (onLater != null) {
                                    onLater!();
                                  } else {
                                    Navigator.of(context)
                                        .pop();
                                  }
                                },
                          style: TextButton.styleFrom(
                            foregroundColor:
                                AppColors.textSecondary,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                          ),
                          child: const Text(
                            'Maybe later',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],

                      // ==============================================
                      // REQUIRED NOTICE
                      // ==============================================

                      if (_isRequired) ...[
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 12,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.55,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Flexible(
                              child: Text(
                                'Update required to continue using the app',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: AppColors
                                      .textSecondary
                                      .withValues(
                                    alpha: 0.60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}

// =================================================================
// CLOSE BUTTON
// =================================================================

class _CloseButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _CloseButton({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.28,
              ),
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 17,
            color: enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// =================================================================
// VERSION INFORMATION
// =================================================================

class _VersionInformation extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final bool requiredUpdate;

  const _VersionInformation({
    required this.currentVersion,
    required this.latestVersion,
    required this.requiredUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _VersionItem(
              label: 'CURRENT',
              version: currentVersion,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          Expanded(
            child: _VersionItem(
              label: requiredUpdate
                  ? 'REQUIRED'
                  : 'LATEST',
              version: latestVersion,
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// VERSION ITEM
// =================================================================

class _VersionItem extends StatelessWidget {
  final String label;
  final String version;
  final bool alignRight;

  const _VersionItem({
    required this.label,
    required this.version,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 6,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
            color: AppColors.textSecondary
                .withValues(
              alpha: 0.52,
            ),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'v$version',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}