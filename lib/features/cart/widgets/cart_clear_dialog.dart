import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

Future<bool> showCartClearDialog(
  BuildContext context,
) async {
  final bool? result =
      await showDialog<bool>(
    context: context,
    barrierColor:
        Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            18,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border
                  .withValues(alpha: 0.40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.12),
                blurRadius: 32,
                offset:
                    const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error
                      .withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .delete_outline_rounded,
                  size: 25,
                  color: AppColors.error,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Clear your cart?',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.4,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'All items will be removed from your cart.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.45,
                  fontWeight:
                      FontWeight.w500,
                  color: AppColors
                      .textSecondary
                      .withValues(alpha: 0.78),
                ),
              ),

              const SizedBox(height: 21),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 47,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(false);
                        },
                        style: OutlinedButton
                            .styleFrom(
                          foregroundColor:
                              AppColors
                                  .textPrimary,
                          side: BorderSide(
                            color: AppColors
                                .border
                                .withValues(
                              alpha: 0.50,
                            ),
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                          ),
                        ),
                        child: const Text(
                          'Keep Items',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: SizedBox(
                      height: 47,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            dialogContext,
                          ).pop(true);
                        },
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              AppColors.error,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(14),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}