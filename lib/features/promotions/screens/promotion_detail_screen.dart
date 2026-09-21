import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

import '../widgets/detailScreen/promotion_detail_header.dart';
import '../widgets/detailScreen/promotion_detail_hero.dart';
import '../widgets/detailScreen/promotion_detail_overview.dart';
import '../widgets/detailScreen/promotion_detail_criteria.dart';
import '../widgets/detailScreen/promotion_detail_targets.dart';
import '../widgets/detailScreen/promotion_detail_groups.dart';
import '../widgets/detailScreen/promotion_detail_validity.dart';

class PromotionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> promotion;

  const PromotionDetailScreen({
    super.key,
    required this.promotion,
  });

  bool get _isMixAndMatch {
    return promotion['promotion_type']
            ?.toString()
            .toLowerCase() ==
        'mix_and_match';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PromotionDetailHeader(
              onBack: () {
                Navigator.of(context).pop();
              },
            ),

            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  6,
                  18,
                  34,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    PromotionDetailHero(
                      promotion: promotion,
                    ),

                    const SizedBox(height: 18),

                    PromotionDetailOverview(
                      promotion: promotion,
                    ),

                    const SizedBox(height: 18),

                    PromotionDetailCriteria(
                      promotion: promotion,
                    ),

                    const SizedBox(height: 18),

                    if (_isMixAndMatch)
                      PromotionDetailGroups(
                        promotion: promotion,
                      )
                    else
                      PromotionDetailTargets(
                        promotion: promotion,
                      ),

                    const SizedBox(height: 18),

                    PromotionDetailValidity(
                      promotion: promotion,
                    ),

                    const SizedBox(height: 20),

                    _AutomaticPromotionNotice(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutomaticPromotionNotice
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            color: Colors.white,
            size: 19,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Applied automatically',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Add qualifying items to your cart. '
                  'The best eligible promotion will be '
                  'applied automatically.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.45,
                    color: Color(0xFFBDBDBD),
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