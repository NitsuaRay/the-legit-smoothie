import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class StoreFeaturedDeals extends StatefulWidget {
  final List<Map<String, dynamic>> promotions;
  final bool isLoading;

  final void Function(Map<String, dynamic> promotion) onPromotionTap;

  const StoreFeaturedDeals({
    super.key,
    required this.promotions,
    required this.isLoading,
    required this.onPromotionTap,
  });

  @override
  State<StoreFeaturedDeals> createState() => _StoreFeaturedDealsState();
}

class _StoreFeaturedDealsState extends State<StoreFeaturedDeals> {
  late final PageController _pageController;

  int _currentPage = 0;
  double _page = 0;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.90);

    _pageController.addListener(_handlePageScroll);
  }

  @override
  void didUpdateWidget(covariant StoreFeaturedDeals oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.promotions.length < oldWidget.promotions.length &&
        _currentPage >= widget.promotions.length) {
      _currentPage = 0;
      _page = 0;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);

    _pageController.dispose();

    super.dispose();
  }

  // =============================================================
  // PAGE ANIMATION
  // =============================================================

  void _handlePageScroll() {
    if (!_pageController.hasClients) {
      return;
    }

    final double nextPage = _pageController.page ?? 0;

    if ((nextPage - _page).abs() < 0.001) {
      return;
    }

    setState(() {
      _page = nextPage;
    });
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const _DealsLoading();
    }

    if (widget.promotions.isEmpty) {
      return const _DealsEmptyState();
    }

    return Column(
      children: [
        // =======================================================
        // PROMOTION CAROUSEL
        // =======================================================
        SizedBox(
          height: 244,
          child: PageView.builder(
            controller: _pageController,

            // One swipe settles on exactly one page.
            physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),

            padEnds: false,

            itemCount: widget.promotions.length,

            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },

            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> promotion = widget.promotions[index];

              final double distance = (_page - index).abs().clamp(0.0, 1.0);

              final double scale = 1.0 - (distance * 0.035);

              final double opacity = 1.0 - (distance * 0.16);

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 18 : 6,
                  right: 6,
                  bottom: 6,
                ),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: opacity,
                    child: _StoreDealCard(
                      promotion: promotion,
                      onTap: () {
                        widget.onPromotionTap(promotion);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // =======================================================
        // PAGE INDICATOR
        // =======================================================
        if (widget.promotions.length > 1) ...[
          const SizedBox(height: 9),

          _PageIndicator(
            count: widget.promotions.length,
            currentPage: _currentPage,
          ),
        ],
      ],
    );
  }
}

// =================================================================
// DEAL CARD
// =================================================================

class _StoreDealCard extends StatelessWidget {
  final Map<String, dynamic> promotion;
  final VoidCallback onTap;

  const _StoreDealCard({required this.promotion, required this.onTap});

  String get _title {
    final String value = promotion['title']?.toString().trim() ?? '';

    return value.isEmpty ? 'Special Offer' : value;
  }

  String? get _bannerUrl {
    final List<dynamic> possibleValues = [
      promotion['banner_url'],
      promotion['banner_image'],
      promotion['image_url'],
      promotion['image'],
    ];

    for (final dynamic value in possibleValues) {
      final String url = value?.toString().trim() ?? '';

      if (url.isNotEmpty) {
        return url;
      }
    }

    return null;
  }

  String get _validityText {
    final DateTime? validUntil = DateTime.tryParse(
      promotion['valid_until']?.toString() ?? '',
    )?.toLocal();

    if (validUntil == null) {
      return 'Available now';
    }

    return 'Valid until ${_formatDate(validUntil)}';
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.055),
                blurRadius: 24,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Column(
              children: [
                // ===============================================
                // BANNER
                // ===============================================
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _PromotionBanner(imageUrl: _bannerUrl),

                      // Very subtle bottom fade.
                      // Keeps the banner itself clean.
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===============================================
                // PROMOTION INFO
                // ===============================================
                Container(
                  height: 72,
                  padding: const EdgeInsets.fromLTRB(15, 10, 12, 10),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      // =========================================
                      // TEXT
                      // =========================================
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.25,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(height: 7),

                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 13,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.65,
                                  ),
                                ),

                                const SizedBox(width: 5),

                                Expanded(
                                  child: Text(
                                    _validityText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      height: 1.1,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // =========================================
                      // OPEN BUTTON
                      // =========================================
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
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
// PROMOTION BANNER
// =================================================================

class _PromotionBanner extends StatelessWidget {
  final String? imageUrl;

  const _PromotionBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;

    if (url == null || url.isEmpty) {
      return const _BannerFallback();
    }

    return Container(
      width: double.infinity,
      color: AppColors.background,
      child: Image.network(
        url,

        // Keep the complete uploaded promotion artwork visible.
        fit: BoxFit.contain,

        alignment: Alignment.center,
        filterQuality: FilterQuality.high,

        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }

              return const _BannerFallback(showLoading: true);
            },

        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              return const _BannerFallback();
            },
      ),
    );
  }
}

// =================================================================
// PAGE INDICATOR
// =================================================================

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentPage;

  const _PageIndicator({required this.count, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (int index) {
        final bool selected = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: selected ? 22 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? AppColors.textPrimary : AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

// =================================================================
// BANNER FALLBACK
// =================================================================

class _BannerFallback extends StatelessWidget {
  final bool showLoading;

  const _BannerFallback({this.showLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.background, AppColors.surface],
        ),
      ),
      child: Center(
        child: showLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.textSecondary,
                ),
              )
            : Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.30),
                  ),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  size: 22,
                  color: AppColors.textSecondary.withValues(alpha: 0.60),
                ),
              ),
      ),
    );
  }
}

// =================================================================
// LOADING
// =================================================================

class _DealsLoading extends StatelessWidget {
  const _DealsLoading();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final double cardWidth = screenWidth * 0.90;

    return SizedBox(
      height: 244,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 18, right: 18),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.28),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.7,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LoadingBlock(
                                width: 170,
                                height: 13,
                                radius: 5,
                              ),

                              const SizedBox(height: 9),

                              const _LoadingBlock(
                                width: 105,
                                height: 9,
                                radius: 4,
                              ),
                            ],
                          ),
                        ),

                        const _LoadingBlock(width: 40, height: 40, radius: 13),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =================================================================
// LOADING BLOCK
// =================================================================

class _LoadingBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _LoadingBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// =================================================================
// EMPTY STATE
// =================================================================

class _DealsEmptyState extends StatelessWidget {
  const _DealsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 20,
                color: AppColors.textSecondary.withValues(alpha: 0.60),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No special offers yet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Check back soon for new deals.',
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
