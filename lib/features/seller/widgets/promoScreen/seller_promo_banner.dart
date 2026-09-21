import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SellerPromoBanner extends StatelessWidget {
  final String? bannerUrl;
  final String? discountTag;
  final String status;
  final String promotionType;

  const SellerPromoBanner({
    super.key,
    required this.bannerUrl,
    required this.discountTag,
    required this.status,
    required this.promotionType,
  });

  bool get _hasBanner {
    return bannerUrl != null &&
        bannerUrl!.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // =====================================================
          // IMAGE / FALLBACK
          // =====================================================

          if (_hasBanner)
            Image.network(
              bannerUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return _buildFallback();
              },
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return _buildLoading();
              },
            )
          else
            _buildFallback(),

          // =====================================================
          // SUBTLE BOTTOM OVERLAY
          // =====================================================

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 72,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.35,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // =====================================================
          // PROMOTION TYPE
          // =====================================================

          Positioned(
            left: 14,
            top: 14,
            child: _buildTypeBadge(),
          ),

          // =====================================================
          // STATUS
          // =====================================================

          Positioned(
            right: 14,
            top: 14,
            child: _buildStatusBadge(),
          ),

          // =====================================================
          // DISCOUNT TAG
          // =====================================================

          if (discountTag != null &&
              discountTag!.trim().isNotEmpty)
            Positioned(
              left: 14,
              bottom: 13,
              child: _buildDiscountTag(),
            ),
        ],
      ),
    );
  }

  // =============================================================
  // FALLBACK
  // =============================================================

  Widget _buildFallback() {
    return Container(
      color: AppColors.textPrimary,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -55,
            child: Container(
              width: 165,
              height: 165,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.05,
                ),
              ),
            ),
          ),

          Positioned(
            right: 50,
            bottom: -65,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.035,
                ),
              ),
            ),
          ),

          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
                border: Border.all(
                  color:
                      Colors.white.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
              child: Icon(
                _promotionIcon,
                size: 23,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // LOADING
  // =============================================================

  Widget _buildLoading() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // =============================================================
  // TYPE BADGE
  // =============================================================

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.62,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.13,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _promotionIcon,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            _promotionTypeLabel,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // STATUS BADGE
  // =============================================================

  Widget _buildStatusBadge() {
    final Color statusColor =
        _statusColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.62,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.13,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            _statusLabel,
            style: const TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // DISCOUNT TAG
  // =============================================================

  Widget _buildDiscountTag() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 210,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 12,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      child: Text(
        discountTag!.trim().toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // =============================================================
  // HELPERS
  // =============================================================

  IconData get _promotionIcon {
    switch (promotionType) {
      case 'mix_and_match':
        return Icons.grid_view_rounded;

      case 'simple_discount':
      default:
        return Icons.local_offer_outlined;
    }
  }

  String get _promotionTypeLabel {
    switch (promotionType) {
      case 'mix_and_match':
        return 'MIX & MATCH';

      case 'simple_discount':
      default:
        return 'DISCOUNT';
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'active':
        return 'ACTIVE';

      case 'upcoming':
        return 'UPCOMING';

      case 'expired':
        return 'EXPIRED';

      case 'disabled':
        return 'DISABLED';

      default:
        return status.toUpperCase();
    }
  }

  Color get _statusColor {
    switch (status) {
      case 'active':
        return Colors.greenAccent;

      case 'upcoming':
        return Colors.amberAccent;

      case 'expired':
        return Colors.redAccent;

      case 'disabled':
      default:
        return Colors.white54;
    }
  }
}