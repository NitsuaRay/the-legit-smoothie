import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? titleWidget;
  final List<Widget>? actions;

  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  // Store status
  final bool showStoreStatus;

  const MainAppBar({
    super.key,
    this.title = 'THE LEGIT SMOOTHIE',
    this.subtitle = 'Freshly made. Made for you.',
    this.titleWidget,
    this.actions,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBackPressed,
    this.showStoreStatus = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(
          alpha: 0.96,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(
              alpha: 0.40,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
              child: Row(
                children: [
                  // =================================================
                  // BACK BUTTON
                  // =================================================

                  if (showBackButton && !showLogo) ...[
                    _AppBarButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap:
                          onBackPressed ??
                          () {
                            Navigator.of(context).maybePop();
                          },
                    ),

                    const SizedBox(width: 12),
                  ],

                  // =================================================
                  // LOGO
                  // =================================================

                  if (showLogo) ...[
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border.withValues(
                            alpha: 0.35,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.035,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
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
                            size: 28,
                            color: AppColors.primary,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),
                  ],

                  // =================================================
                  // BRAND / TITLE
                  // =================================================

                  Expanded(
                    child:
                        titleWidget ??
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.25,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            if (subtitle != null &&
                                subtitle!.trim().isNotEmpty) ...[
                              const SizedBox(height: 5),

                              Text(
                                subtitle!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  height: 1.1,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary
                                      .withValues(
                                    alpha: 0.78,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                  ),

                
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    ...actions!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ===================================================================
// REUSABLE APP BAR BUTTON
// ===================================================================

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.45,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}