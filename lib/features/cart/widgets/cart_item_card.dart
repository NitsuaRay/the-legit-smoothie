import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../catalog/screens/product_detail_modal.dart';
import '../services/cart_service.dart';
import 'cart_customizations.dart';
import 'cart_quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final dynamic item;
  final CartService cartService;

  const CartItemCard({
    super.key,
    required this.item,
    required this.cartService,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(
            alpha: 0.07,
          ),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(
              alpha: 0.10,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 19,
            color: AppColors.error,
          ),
        ),
      ),

      onDismissed: (_) {
        cartService.removeItem(item.id);
      },

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border.withValues(
              alpha: 0.30,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ProductDetailModal.show(
                context,
                item.product,
                cartItem: item,
              );
            },
            borderRadius:
                BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                children: [
                  // =============================================
                  // PRODUCT
                  // =============================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _ProductImage(
                        imageUrl:
                            item.product.imageUrl,
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'CART ITEM',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 1,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.50,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow
                                  .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                height: 1.15,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: -0.4,
                                color: AppColors
                                    .textPrimary,
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              '${AppHelpers.formatCurrency(item.unitPrice)} each',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w600,
                                color: AppColors
                                    .textSecondary
                                    .withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            _CustomizeButton(
                              onTap: () {
                                ProductDetailModal
                                    .show(
                                  context,
                                  item.product,
                                  cartItem: item,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // =============================================
                  // OPTIONS
                  // =============================================

                  if (item.selectedOptions
                      .isNotEmpty) ...[
                    const SizedBox(height: 13),

                    CartCustomizations(
                      options:
                          item.selectedOptions,
                    ),
                  ],

                  const SizedBox(height: 14),

                  Divider(
                    height: 1,
                    color: AppColors.border
                        .withValues(alpha: 0.25),
                  ),

                  const SizedBox(height: 13),

                  // =============================================
                  // QUANTITY + TOTAL
                  // =============================================

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'QUANTITY',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.8,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          CartQuantitySelector(
                            quantity:
                                item.quantity,
                            onDecrease: () {
                              cartService
                                  .decrementQuantity(
                                item.id,
                              );
                            },
                            onIncrease: () {
                              cartService
                                  .incrementQuantity(
                                item.id,
                              );
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ITEM TOTAL',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: 0.8,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 7,
                          ),

                          Text(
                            AppHelpers
                                .formatCurrency(
                              item.totalPrice,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 19,
                              height: 1,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -0.6,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            '${item.quantity} × '
                            '${AppHelpers.formatCurrency(item.unitPrice)}',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight:
                                  FontWeight.w500,
                              color: AppColors
                                  .textSecondary
                                  .withValues(
                                alpha: 0.60,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(15),
        child: imageUrl != null &&
                imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const _Placeholder();
                },
              )
            : const _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.local_drink_outlined,
        size: 25,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _CustomizeButton
    extends StatelessWidget {
  final VoidCallback onTap;

  const _CustomizeButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 12,
                color:
                    AppColors.textPrimary,
              ),
              SizedBox(width: 5),
              Text(
                'Customize',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}