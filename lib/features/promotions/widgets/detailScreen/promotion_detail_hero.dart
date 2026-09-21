import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PromotionDetailHero extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailHero({
    super.key,
    required this.promotion,
  });

  String get _title {
    return promotion['title']?.toString() ??
        'Promotion';
  }

  String get _description {
    return promotion['description']
            ?.toString()
            .trim() ??
        '';
  }

  String get _tag {
    return promotion['discount_tag']
            ?.toString()
            .trim() ??
        '';
  }

  String get _bannerUrl {
    return promotion['banner_url']
            ?.toString()
            .trim() ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.30,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (_bannerUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                _bannerUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return _placeholder();
                },
              ),
            )
          else
            _placeholder(),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                if (_tag.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.textPrimary,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Text(
                      _tag.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 7.5,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.7,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (_tag.isNotEmpty)
                  const SizedBox(height: 12),

                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                if (_description.isNotEmpty) ...[
                  const SizedBox(height: 9),

                  Text(
                    _description,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.5,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 145,
      color: AppColors.textPrimary,
      child: const Center(
        child: Icon(
          Icons.local_offer_outlined,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }
}