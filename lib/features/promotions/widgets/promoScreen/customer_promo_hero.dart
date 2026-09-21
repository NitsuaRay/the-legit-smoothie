import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoHero
    extends StatefulWidget {
  final List<Map<String, dynamic>> promotions;

  const CustomerPromoHero({
    super.key,
    required this.promotions,
  });

  @override
  State<CustomerPromoHero> createState() =>
      _CustomerPromoHeroState();
}

class _CustomerPromoHeroState
    extends State<CustomerPromoHero> {
  final PageController _controller =
      PageController(
    viewportFraction: 0.92,
  );

  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 166,
          child: PageView.builder(
            controller: _controller,
            itemCount:
                widget.promotions.length,
            onPageChanged: (value) {
              setState(() {
                _page = value;
              });
            },
            itemBuilder:
                (context, index) {
              final promo =
                  widget.promotions[index];

              final String title =
                  promo['title']
                          ?.toString() ??
                      'Special offer';

              final String tag =
                  promo['discount_tag']
                          ?.toString() ??
                      'SPECIAL DEAL';

              final String? image =
                  promo['banner_url']
                      ?.toString();

              return Padding(
                padding:
                    const EdgeInsets.only(
                  right: 9,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    21,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image != null &&
                          image
                              .trim()
                              .isNotEmpty)
                        Image.network(
                          image,
                          fit:
                              BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  _fallback(),
                        )
                      else
                        _fallback(),

                      DecoratedBox(
                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin: Alignment
                                .centerLeft,
                            end: Alignment
                                .centerRight,
                            colors: [
                              Colors.black
                                  .withValues(
                                alpha: 0.78,
                              ),
                              Colors.black
                                  .withValues(
                                alpha: 0.12,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                            const EdgeInsets
                                .all(
                          17,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .end,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors
                                    .white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  30,
                                ),
                              ),
                              child: Text(
                                tag
                                    .toUpperCase(),
                                style:
                                    const TextStyle(
                                  fontSize: 6,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                  letterSpacing:
                                      0.7,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 9,
                            ),

                            Text(
                              title,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                height: 1,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                letterSpacing:
                                    -0.7,
                                color:
                                    Colors.white,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              'Limited-time offer',
                              style:
                                  TextStyle(
                                fontSize: 8.5,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color: Colors
                                    .white
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (widget.promotions.length >
            1) ...[
          const SizedBox(height: 9),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children:
                List.generate(
              widget.promotions.length,
              (index) {
                final bool selected =
                    index == _page;

                return AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 2,
                  ),
                  width:
                      selected ? 18 : 5,
                  height: 5,
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? AppColors
                            .textPrimary
                        : AppColors.border,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 18),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.textPrimary,
      child: Align(
        alignment:
            Alignment.centerRight,
        child: Padding(
          padding:
              const EdgeInsets.only(
            right: 30,
          ),
          child: Icon(
            Icons
                .local_offer_outlined,
            size: 80,
            color: Colors.white
                .withValues(
              alpha: 0.07,
            ),
          ),
        ),
      ),
    );
  }
}