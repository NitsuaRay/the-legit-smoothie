import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreHero extends StatelessWidget {
  final bool isStoreOpen;
  final bool isLoading;
  final VoidCallback onBrowseMenu;

  const StoreHero({
    super.key,
    required this.isStoreOpen,
    required this.isLoading,
    required this.onBrowseMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        0,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius:
              BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                alpha: 0.11,
              ),
              blurRadius: 28,
              offset:
                  const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(26),
          child: Stack(
            children: [
              // =================================================
              // BACKGROUND DECORATION
              // =================================================

              Positioned(
                top: -65,
                right: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(
                      alpha: 0.035,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 45,
                right: -20,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withValues(
                        alpha: 0.035,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -70,
                left: -45,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withValues(
                      alpha: 0.025,
                    ),
                  ),
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================

              Padding(
                padding:
                    const EdgeInsets.all(21),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(),

                    const SizedBox(height: 23),

                    const Text(
                      'Sip something\nlegit.',
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.05,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: -1.2,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: 280,
                      child: Text(
                        _description,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.5,
                          fontWeight:
                              FontWeight.w500,
                          color: Colors.white
                              .withValues(
                            alpha: 0.62,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _HeroFeature(
                          icon:
                              Icons.eco_outlined,
                          label:
                              'Fresh ingredients',
                        ),

                        const SizedBox(
                          width: 17,
                        ),

                        _HeroFeature(
                          icon: Icons
                              .restaurant_outlined,
                          label:
                              'Made to order',
                        ),
                      ],
                    ),

                    const SizedBox(height: 23),

                    Material(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      child: InkWell(
                        onTap: onBrowseMenu,
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets
                              .symmetric(
                            horizontal: 16,
                          ),
                          child: const Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                Icons
                                    .restaurant_menu_rounded,
                                size: 17,
                                color: AppColors
                                    .textPrimary,
                              ),

                              SizedBox(width: 9),

                              Text(
                                'Browse Menu',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),

                              SizedBox(width: 13),

                              Icon(
                                Icons
                                    .arrow_forward_rounded,
                                size: 15,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // DESCRIPTION
  // =============================================================

  String get _description {
    if (isLoading) {
      return 'Checking store availability and '
          'getting everything ready for you.';
    }

    if (isStoreOpen) {
      return 'Discover refreshing smoothies '
          'prepared fresh for every order.';
    }

    return 'We\'re currently closed for orders. '
        'You can still explore our menu and deals.';
  }

  // =============================================================
  // STATUS BADGE
  // =============================================================

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.09,
        ),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLoading
                ? Icons
                    .hourglass_empty_rounded
                : isStoreOpen
                    ? Icons
                        .local_drink_outlined
                    : Icons
                        .schedule_rounded,
            size: 13,
            color: Colors.white.withValues(
              alpha: 0.85,
            ),
          ),

          const SizedBox(width: 7),

          Text(
            isLoading
                ? 'CHECKING STORE'
                : isStoreOpen
                    ? 'OPEN FOR ORDERS'
                    : 'CURRENTLY CLOSED',
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: Colors.white
                  .withValues(
                alpha: 0.80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// HERO FEATURE
// =================================================================

class _HeroFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroFeature({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: Colors.white
                  .withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 13,
              color: Colors.white
                  .withValues(
                alpha: 0.80,
              ),
            ),
          ),

          const SizedBox(width: 7),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight:
                    FontWeight.w700,
                color: Colors.white
                    .withValues(
                  alpha: 0.72,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}