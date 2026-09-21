import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerPromoLoading
    extends StatelessWidget {
  const CustomerPromoLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        18,
        0,
        18,
        32,
      ),
      child: Column(
        children:
            List.generate(
          3,
          (index) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 13,
            ),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(
                9,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.surface,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.25,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 145,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius
                              .circular(
                        17,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Container(
                    width: 80,
                    height: 7,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Container(
                    width: 190,
                    height: 14,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Container(
                    width:
                        double.infinity,
                    height: 9,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Container(
                    width: 220,
                    height: 9,
                    decoration:
                        BoxDecoration(
                      color: AppColors
                          .background,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}