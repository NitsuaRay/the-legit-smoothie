import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreInformationCard extends StatelessWidget {
  final String? storeAddress;
  final VoidCallback? onViewMap;

  const StoreInformationCard({
    super.key,
    required this.storeAddress,
    this.onViewMap,
  });

  String get _address {
    final String value = storeAddress?.trim() ?? '';

    if (value.isEmpty) {
      return 'Store address unavailable';
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          // =====================================================
          // LOCATION
          // =====================================================
          _LocationCard(address: _address, onViewMap: onViewMap),

          const SizedBox(height: 11),

          // =====================================================
          // HOURS + ORDER OPTIONS
          // =====================================================
          SizedBox(
            height: 145,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                Expanded(
                  child: _QuickInfoCard(
                    icon: Icons.schedule_rounded,
                    eyebrow: 'STORE HOURS',
                    title: '11 AM – 9 PM',
                    subtitle: 'Open daily',
                  ),
                ),

                SizedBox(width: 10),

                Expanded(
                  child: _QuickInfoCard(
                    icon: Icons.delivery_dining_rounded,
                    eyebrow: 'ORDER OPTIONS',
                    title: 'Pickup & Delivery',
                    subtitle: 'Choose what works for you',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// LOCATION CARD
// =================================================================

class _LocationCard extends StatelessWidget {
  final String address;
  final VoidCallback? onViewMap;

  const _LocationCard({required this.address, required this.onViewMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            // ===================================================
            // MAP PREVIEW AREA
            // ===================================================
            _MapPreview(address: address, onTap: onViewMap),

            // ===================================================
            // ADDRESS
            // ===================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // =============================================
                  // LOCATION ICON
                  // =============================================
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // =============================================
                  // ADDRESS TEXT
                  // =============================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STORE LOCATION',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.52,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Visit our store',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.25,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (onViewMap != null) ...[
                    const SizedBox(width: 10),

                    Material(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        onTap: onViewMap,
                        borderRadius: BorderRadius.circular(13),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// MAP PREVIEW
// =================================================================

class _MapPreview extends StatelessWidget {
  final String address;
  final VoidCallback? onTap;

  const _MapPreview({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 118,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // =================================================
              // PREMIUM MAP PLACEHOLDER
              //
              // Replace this background with the real map widget
              // once the map package/location is connected.
              // =================================================
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.background, AppColors.surface],
                  ),
                ),
              ),

              // =================================================
              // DECORATIVE "STREETS"
              // =================================================
              Positioned(
                left: -20,
                top: 35,
                child: Transform.rotate(
                  angle: -0.12,
                  child: Container(
                    width: 220,
                    height: 2,
                    color: AppColors.border.withValues(alpha: 0.42),
                  ),
                ),
              ),

              Positioned(
                right: -30,
                top: 75,
                child: Transform.rotate(
                  angle: 0.18,
                  child: Container(
                    width: 260,
                    height: 2,
                    color: AppColors.border.withValues(alpha: 0.32),
                  ),
                ),
              ),

              Positioned(
                left: 95,
                top: -35,
                child: Transform.rotate(
                  angle: 0.65,
                  child: Container(
                    width: 2,
                    height: 210,
                    color: AppColors.border.withValues(alpha: 0.30),
                  ),
                ),
              ),

              // =================================================
              // LOCATION PIN
              // =================================================
              Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // =================================================
              // MAP LABEL
              // =================================================
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: 12,
                        color: AppColors.textPrimary,
                      ),

                      SizedBox(width: 5),

                      Text(
                        'OUR STORE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (onTap != null)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VIEW MAP',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(width: 5),

                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ],
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

// =================================================================
// QUICK INFORMATION CARD
// =================================================================

class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;

  const _QuickInfoCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // ICON
          // =====================================================
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: AppColors.textPrimary),
          ),

          const Spacer(),

          // =====================================================
          // EYEBROW
          // =====================================================
          Text(
            eyebrow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
              color: AppColors.textSecondary.withValues(alpha: 0.48),
            ),
          ),

          const SizedBox(height: 5),

          // =====================================================
          // TITLE
          // =====================================================
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          // =====================================================
          // SUBTITLE
          // =====================================================
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.66),
            ),
          ),
        ],
      ),
    );
  }
}
