import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/catalog/screens/product_detail_modal.dart';
import 'package:the_legit_smoothie/features/checkout/screens/checkout_screen.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import 'package:the_legit_smoothie/shared/widgets/main_navigation_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CLEAR CART
  // ============================================================

  void _confirmClearCart() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ICON
                // ==================================================
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 27,
                    color: AppColors.error,
                  ),
                ),

                const SizedBox(height: 17),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  'Clear your cart?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'All items in your cart will be removed. '
                  'You can always add them again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.82),
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // ACTIONS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: AppColors.background,
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.55),
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Keep Items',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            _cartService.clearCart();

                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;

    final int totalCount = cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: MainAppBar(
        showLogo: false,
        showBackButton: false,
        titleWidget: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 19,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.45,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    cartItems.isEmpty
                        ? 'No items added'
                        : '$totalCount '
                              '${totalCount == 1 ? 'item' : 'items'} '
                              'ready for checkout',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _confirmClearCart,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 14,
                        color: AppColors.error.withValues(alpha: 0.85),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // =================================================
                // CART ITEMS
                // =================================================
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      14,
                      AppConstants.defaultPadding,
                      24,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,

                        // =========================================
                        // SWIPE DELETE BACKGROUND
                        // =========================================
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.075),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.11),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                          ),
                        ),

                        onDismissed: (_) {
                          _cartService.removeItem(item.id);
                        },

                        // =========================================
                        // PRODUCT CARD
                        // =========================================
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
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.32,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.035,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // =====================================================
                                  // PRODUCT HERO
                                  // =====================================================
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // =================================================
                                        // PRODUCT IMAGE
                                        // =================================================
                                        Container(
                                          width: 118,
                                          height: 128,
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border
                                                  .withValues(alpha: 0.22),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              17,
                                            ),
                                            child:
                                                item.product.imageUrl != null &&
                                                    item
                                                        .product
                                                        .imageUrl!
                                                        .isNotEmpty
                                                ? Image.network(
                                                    item.product.imageUrl!,
                                                    width: double.infinity,
                                                    height: double.infinity,

                                                    // IMPORTANT:
                                                    // contain prevents smoothie/product
                                                    // photos from being badly cropped.
                                                    fit: BoxFit.contain,

                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return _buildPlaceholderImage();
                                                        },
                                                  )
                                                : _buildPlaceholderImage(),
                                          ),
                                        ),

                                        const SizedBox(width: 15),

                                        // =================================================
                                        // PRODUCT INFORMATION
                                        // =================================================
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // =================================================
                                              // PRODUCT LABEL
                                              // =================================================
                                              Text(
                                                'YOUR ITEM',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.1,
                                                  color: AppColors.textSecondary
                                                      .withValues(alpha: 0.50),
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              // =================================================
                                              // NAME
                                              // =================================================
                                              Text(
                                                item.product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  height: 1.15,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: -0.55,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),

                                              const SizedBox(height: 9),

                                              // =================================================
                                              // UNIT PRICE
                                              // =================================================
                                              Row(
                                                children: [
                                                  Text(
                                                    AppHelpers.formatCurrency(
                                                      item.unitPrice,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: -0.2,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),

                                                  const SizedBox(width: 5),

                                                  Text(
                                                    'each',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .textSecondary
                                                          .withValues(
                                                            alpha: 0.65,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 13),

                                              // =================================================
                                              // EDIT CUSTOMIZATION
                                              // =================================================
                                              Material(
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
                                                      BorderRadius.circular(10),
                                                  child: Ink(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.background,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: AppColors.border
                                                            .withValues(
                                                              alpha: 0.30,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.tune_rounded,
                                                          size: 14,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),

                                                        SizedBox(width: 6),

                                                        Text(
                                                          'Customize',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .textPrimary,
                                                          ),
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

                                  // =====================================================
                                  // CUSTOMIZATIONS
                                  // =====================================================
                                  if (item.selectedOptions.isNotEmpty) ...[
                                    const SizedBox(height: 16),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(13),
                                        decoration: BoxDecoration(
                                          color: AppColors.background
                                              .withValues(alpha: 0.72),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.tune_rounded,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),

                                                const SizedBox(width: 6),

                                                Text(
                                                  'CUSTOMIZATIONS',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.9,
                                                    color: AppColors
                                                        .textSecondary
                                                        .withValues(
                                                          alpha: 0.58,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 10),

                                            Wrap(
                                              spacing: 7,
                                              runSpacing: 7,
                                              children: item.selectedOptions.map((
                                                opt,
                                              ) {
                                                final String name =
                                                    opt['name']?.toString() ??
                                                    '';

                                                final double extraPrice =
                                                    (opt['extra_price'] as num?)
                                                        ?.toDouble() ??
                                                    0;

                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 7,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          9,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.border
                                                          .withValues(
                                                            alpha: 0.35,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        name,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                      ),

                                                      if (extraPrice > 0) ...[
                                                        const SizedBox(
                                                          width: 5,
                                                        ),

                                                        Text(
                                                          '+${AppHelpers.formatCurrency(extraPrice)}',
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .textSecondary
                                                                .withValues(
                                                                  alpha: 0.72,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // =====================================================
                                  // DIVIDER
                                  // =====================================================
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.border.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                  ),

                                  // =====================================================
                                  // BOTTOM SECTION
                                  // =====================================================
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      14,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // =================================================
                                        // QUANTITY
                                        // =================================================
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'QUANTITY',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.9,
                                                color: AppColors.textSecondary
                                                    .withValues(alpha: 0.52),
                                              ),
                                            ),

                                            const SizedBox(height: 7),

                                            Container(
                                              height: 42,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                                border: Border.all(
                                                  color: AppColors.border
                                                      .withValues(alpha: 0.30),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _buildQuantityButton(
                                                    icon: Icons.remove_rounded,
                                                    onTap: () {
                                                      _cartService
                                                          .decrementQuantity(
                                                            item.id,
                                                          );
                                                    },
                                                  ),

                                                  Container(
                                                    width: 38,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ),

                                                  _buildQuantityButton(
                                                    icon: Icons.add_rounded,
                                                    onTap: () {
                                                      _cartService
                                                          .incrementQuantity(
                                                            item.id,
                                                          );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const Spacer(),

                                        // =================================================
                                        // ITEM TOTAL
                                        // =================================================
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'ITEM TOTAL',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.9,
                                                color: AppColors.textSecondary
                                                    .withValues(alpha: 0.52),
                                              ),
                                            ),

                                            const SizedBox(height: 7),

                                            Text(
                                              AppHelpers.formatCurrency(
                                                item.totalPrice,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 21,
                                                height: 1,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.7,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),

                                            const SizedBox(height: 5),

                                            Text(
                                              '${item.quantity} × '
                                              '${AppHelpers.formatCurrency(item.unitPrice)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textSecondary
                                                    .withValues(alpha: 0.62),
                                              ),
                                            ),
                                          ],
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
                    },
                  ),
                ),

                // =================================================
                // ORDER SUMMARY
                // =================================================
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    17,
                    AppConstants.defaultPadding,
                    14 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.28),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.045),
                        blurRadius: 28,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // =============================================
                      // SUMMARY HEADER
                      // =============================================
                      Row(
                        children: [
                          Text(
                            'ORDER SUMMARY',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.48,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '$totalCount '
                            '${totalCount == 1 ? 'ITEM' : 'ITEMS'}',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.48,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // =============================================
                      // SUBTOTAL
                      // =============================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  'Delivery fee is calculated next',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.52,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            AppHelpers.formatCurrency(_cartService.subtotal),
                            style: const TextStyle(
                              fontSize: 22,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.7,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // =============================================
                      // CHECKOUT BUTTON
                      // =============================================
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _showCheckoutConfirmation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.15,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(width: 10),

                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // CHECKOUT CONFIRMATION
  // ============================================================

  Future<void> _showCheckoutConfirmation() async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ICON
                // ==================================================
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 25,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 17),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  'Ready to checkout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Review your items before continuing '
                  'to delivery and payment details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.80),
                  ),
                ),

                const SizedBox(height: 19),

                // ==================================================
                // INFORMATION
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _CheckoutInfoRow(
                        icon: Icons.inventory_2_outlined,
                        text: 'Confirm your items and quantities.',
                      ),

                      SizedBox(height: 11),

                      _CheckoutInfoRow(
                        icon: Icons.edit_off_outlined,
                        text: 'Items cannot be edited after placing the order.',
                      ),

                      SizedBox(height: 11),

                      _CheckoutInfoRow(
                        icon: Icons.local_shipping_outlined,
                        text: 'Delivery details will be confirmed next.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // ACTIONS
                // ==================================================
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: AppColors.background,
                            elevation: 0,
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.55),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Review Cart',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldProceed != true) {
      return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const CheckoutScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final fadeAnimation = Tween<double>(
            begin: 0,
            end: 1,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding * 2,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Your cart is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              'Add your favorite smoothies, drinks, '
              'and snacks to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.72),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined, size: 16),

                    SizedBox(width: 8),

                    Text(
                      'Explore Menu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

  // ============================================================
  // PLACEHOLDER IMAGE
  // ============================================================

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
          ),
          child: const Icon(
            Icons.local_drink_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // QUANTITY BUTTON
  // ============================================================

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 30,
          height: 34,
          child: Center(
            child: Icon(icon, size: 14, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// CHECKOUT INFO ROW
// ===================================================================

class _CheckoutInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CheckoutInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 14, color: AppColors.textPrimary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.80),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
