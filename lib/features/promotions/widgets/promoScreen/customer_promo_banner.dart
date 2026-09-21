import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoBanner
    extends StatelessWidget {
  final String? bannerUrl;
  final String? discountTag;
  final bool upcoming;
  final String promotionType;

  const CustomerPromoBanner({
    super.key,
    required this.bannerUrl,
    required this.discountTag,
    required this.upcoming,
    required this.promotionType,
  });

  String get _typeLabel {
    switch (promotionType) {
      case 'mix_and_match':
        return 'MIX & MATCH';

      default:
        return 'SPECIAL OFFER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBanner =
        bannerUrl != null &&
        bannerUrl!.trim().isNotEmpty;

    return AspectRatio(
      aspectRatio: 16 / 7.3,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasBanner)
              Image.network(
                bannerUrl!,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        _fallback(),
              )
            else
              _fallback(),

            if (hasBanner)
              DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin: Alignment
                        .topCenter,
                    end: Alignment
                        .bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(
                        alpha: 0.02,
                      ),
                      Colors.black
                          .withValues(
                        alpha: 0.38,
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              top: 11,
              left: 11,
              child: _BannerPill(
                text: _typeLabel,
              ),
            ),

            Positioned(
              top: 11,
              right: 11,
              child: _BannerPill(
                text: upcoming
                    ? 'SOON'
                    : 'LIVE',
                inverted: !upcoming,
              ),
            ),

            if (discountTag != null &&
                discountTag!
                    .trim()
                    .isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  discountTag!
                      .trim()
                      .toUpperCase(),
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    height: 0.95,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing:
                        -0.7,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color:
                            Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.textPrimary,
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -28,
            child: Container(
              width: 120,
              height: 120,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                border: Border.all(
                  width: 22,
                  color: Colors.white
                      .withValues(
                    alpha: 0.055,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 28,
            bottom: -46,
            child: Container(
              width: 100,
              height: 100,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: Colors.white
                    .withValues(
                  alpha: 0.045,
                ),
              ),
            ),
          ),

          Center(
            child: Icon(
              Icons
                  .local_offer_outlined,
              size: 48,
              color: Colors.white
                  .withValues(
                alpha: 0.12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPill
    extends StatelessWidget {
  final String text;
  final bool inverted;

  const _BannerPill({
    required this.text,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white
            : Colors.black.withValues(
                alpha: 0.58,
              ),
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 6,
          height: 1,
          fontWeight:
              FontWeight.w900,
          letterSpacing: 0.7,
          color: inverted
              ? AppColors.textPrimary
              : Colors.white,
        ),
      ),
    );
  }
}