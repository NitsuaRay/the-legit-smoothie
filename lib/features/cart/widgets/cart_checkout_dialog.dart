import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

Future<bool> showCartCheckoutDialog(
  BuildContext context,
) async {
  final bool? result =
      await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor:
        Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        insetPadding:
            const EdgeInsets.symmetric(
          horizontal: 22,
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
                    .withValues(alpha: 0.14),
                blurRadius: 34,
                offset:
                    const Offset(0, 16),
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
                  color:
                      AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border
                        .withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons
                      .shopping_bag_outlined,
                  size: 24,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Ready to checkout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.45,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Review your order before continuing '
                'to delivery and payment details.',
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

              const SizedBox(height: 18),

              Container(
                padding:
                    const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color:
                      AppColors.background,
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: const Column(
                  children: [
                    _InfoRow(
                      icon: Icons
                          .inventory_2_outlined,
                      text:
                          'Confirm your items and quantities.',
                    ),

                    SizedBox(height: 10),

                    _InfoRow(
                      icon: Icons
                          .edit_off_outlined,
                      text:
                          'Items cannot be edited after placing the order.',
                    ),

                    SizedBox(height: 10),

                    _InfoRow(
                      icon: Icons
                          .local_shipping_outlined,
                      text:
                          'Delivery details will be confirmed next.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                          'Review Cart',
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
                              AppColors
                                  .textPrimary,
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
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons
                                  .arrow_forward_rounded,
                              size: 15,
                            ),
                          ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 13,
            color:
                AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 6,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.35,
                fontWeight:
                    FontWeight.w500,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.80,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}