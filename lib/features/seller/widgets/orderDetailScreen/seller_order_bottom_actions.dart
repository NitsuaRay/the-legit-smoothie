import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SellerOrderBottomActions extends StatelessWidget {
  final String status;
  final String primaryActionLabel;
  final IconData primaryActionIcon;

  final bool isUpdating;
  final bool canUpdate;

  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onCancelPressed;

  const SellerOrderBottomActions({
    super.key,
    required this.status,
    required this.primaryActionLabel,
    required this.primaryActionIcon,
    required this.isUpdating,
    required this.canUpdate,
    required this.onPrimaryPressed,
    required this.onCancelPressed,
  });

  bool get _isTerminal =>
      status == 'completed' ||
      status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    if (_isTerminal) {
      return _buildTerminalState();
    }

    return _buildActions();
  }

  // ============================================================
  // TERMINAL STATE
  // ============================================================

  Widget _buildTerminalState() {
    final bool completed =
        status == 'completed';

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          11,
          AppConstants.defaultPadding,
          11,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(
                alpha: 0.35,
              ),
            ),
          ),
        ),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completed
                      ? Icons.task_alt_rounded
                      : Icons.cancel_outlined,
                  size: 18,
                  color: completed
                      ? AppColors.success
                      : AppColors.error,
                ),

                const SizedBox(width: 7),

                Text(
                  completed
                      ? 'Order Completed'
                      : 'Order Cancelled',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          11,
          AppConstants.defaultPadding,
          11,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(
                alpha: 0.35,
              ),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.035,
              ),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // ============================================
            // CANCEL BUTTON
            // ============================================
            SizedBox(
              width: 50,
              height: 50,
              child: OutlinedButton(
                onPressed:
                    isUpdating ? null : onCancelPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: BorderSide(
                    color: AppColors.error.withValues(
                      alpha: 0.25,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: 19,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ============================================
            // PRIMARY ACTION
            // ============================================
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      isUpdating || !canUpdate
                          ? null
                          : onPrimaryPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(
                      alpha: 0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              primaryActionIcon,
                              size: 18,
                            ),

                            const SizedBox(width: 7),

                            Text(
                              primaryActionLabel,
                              style:
                                  const TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}