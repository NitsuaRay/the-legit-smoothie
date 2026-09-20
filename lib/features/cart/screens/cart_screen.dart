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
    setState(() {});
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =========================================================
                // ICON
                // =========================================================
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    size: 30,
                    color: AppColors.error,
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================================
                // TITLE
                // =========================================================
                const Text(
                  'Clear your cart?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // =========================================================
                // DESCRIPTION
                // =========================================================
                Text(
                  'This will remove all items from your cart. '
                  'You can always add them again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                  ),
                ),

                const SizedBox(height: 22),

                // =========================================================
                // ACTIONS
                // =========================================================
                Row(
                  children: [
                    // CANCEL
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            backgroundColor: AppColors.background,
                            side: BorderSide(
                              color: AppColors.border.withValues(alpha: 0.7),
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // CLEAR ALL
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _cartService.clearCart();
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 18),
                              SizedBox(width: 7),
                              Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 13.5,
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

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;
    final int totalCount = cartItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MainAppBar(
        showLogo: false,
        showBackButton: false,
        titleWidget: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(
              width: 10,
            ), // Added missing gap between icon and text
            // Wrapped in Expanded to avoid horizontal overflow
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gradient "My Cart" Text
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.textPrimary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cartItems.isEmpty
                        ? 'Your cart is currently empty'
                        : '$totalCount ${totalCount == 1 ? 'item selected' : 'items selected'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            Material(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _confirmClearCart,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultPadding,
                      8,
                      AppConstants.defaultPadding,
                      120,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,

                        // DELETE BACKGROUND
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.12),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 22),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 24,
                            ),
                          ),
                        ),

                        onDismissed: (_) {
                          _cartService.removeItem(item.id);
                        },

                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              ProductDetailModal.show(
                                context,
                                item.product,
                                cartItem: item,
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(22),

                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.45,
                                  ),
                                  width: 1,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.025,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.025,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // =========================================================
                                  // PRODUCT IMAGE
                                  // =========================================================
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.40,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          item.product.imageUrl != null &&
                                                  item
                                                      .product
                                                      .imageUrl!
                                                      .isNotEmpty
                                              ? Image.network(
                                                  item.product.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildPlaceholderImage(),
                                                )
                                              : _buildPlaceholderImage(),

                                          // Subtle image overlay
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            bottom: 0,
                                            height: 24,
                                            child: IgnorePointer(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withValues(
                                                        alpha: 0.08,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // =========================================================
                                  // MAIN PRODUCT CONTENT
                                  // =========================================================
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product name + edit button
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.product.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.25,
                                                  color: AppColors.textPrimary,
                                                  height: 1.15,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 6),

                                            // Edit
                                            InkWell(
                                              onTap: () {
                                                ProductDetailModal.show(
                                                  context,
                                                  item.product,
                                                  cartItem: item,
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: AppColors.border
                                                        .withValues(
                                                          alpha: 0.45,
                                                        ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // ===================================================
                                        // OPTIONS
                                        // ===================================================
                                        if (item.selectedOptions.isNotEmpty)
                                          Wrap(
                                            spacing: 5,
                                            runSpacing: 5,
                                            children: item.selectedOptions
                                                .take(3)
                                                .map((opt) {
                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withValues(
                                                            alpha: 0.055,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: AppColors.primary
                                                            .withValues(
                                                              alpha: 0.10,
                                                            ),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      opt['name']?.toString() ??
                                                          '',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .textSecondary
                                                            .withValues(
                                                              alpha: 0.95,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                })
                                                .toList(),
                                          ),

                                        const SizedBox(height: 12),

                                        // ===================================================
                                        // PRICE
                                        // ===================================================
                                        Text(
                                          AppHelpers.formatCurrency(
                                            item.totalPrice,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.3,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // =========================================================
                                  // RIGHT SIDE CONTROLS
                                  // =========================================================
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Quantity stepper
                                      Container(
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border.withValues(
                                              alpha: 0.55,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildQuantityButton(
                                              icon: Icons.remove_rounded,
                                              onTap: () {
                                                _cartService.decrementQuantity(
                                                  item.id,
                                                );
                                              },
                                            ),

                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),

                                            _buildQuantityButton(
                                              icon: Icons.add_rounded,
                                              onTap: () {
                                                _cartService.incrementQuantity(
                                                  item.id,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Remove button
                                      InkWell(
                                        onTap: () {
                                          _cartService.removeItem(item.id);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.delete_outline_rounded,
                                            size: 17,
                                            color: AppColors.error.withValues(
                                              alpha: 0.75,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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

                // ============================================================
                // ORDER SUMMARY FOOTER
                // ============================================================
                Container(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    16,
                    AppConstants.defaultPadding,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ========================================================
                      // SUBTOTAL
                      // ========================================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            AppHelpers.formatCurrency(_cartService.subtotal),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ========================================================
                      // PROCEED TO CHECKOUT BUTTON
                      // ========================================================
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            // ====================================================
                            // CONFIRMATION DIALOG
                            // ====================================================
                            final bool? shouldProceed = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.14,
                                          ),
                                          blurRadius: 32,
                                          offset: const Offset(0, 18),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          22,
                                          22,
                                          22,
                                          18,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // ======================================
                                            // ICON
                                            // ======================================
                                            Container(
                                              width: 62,
                                              height: 62,
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withValues(
                                                  alpha: 0.12,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.shopping_bag_outlined,
                                                color: Colors.amber,
                                                size: 34,
                                              ),
                                            ),

                                            const SizedBox(height: 18),

                                            // ======================================
                                            // TITLE
                                            // ======================================
                                            const Text(
                                              'Proceed to Checkout?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 22,
                                                height: 1.15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.4,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            // ======================================
                                            // DESCRIPTION
                                            // ======================================
                                            const Text(
                                              'Please review your cart carefully before continuing.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1.45,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // ======================================
                                            // INFORMATION BOX
                                            // ======================================
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.06),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.12),
                                                ),
                                              ),
                                              child: const Column(
                                                children: [
                                                  _CheckoutInfoRow(
                                                    icon: Icons
                                                        .inventory_2_outlined,
                                                    text:
                                                        'Confirm all items and quantities.',
                                                  ),

                                                  SizedBox(height: 12),

                                                  _CheckoutInfoRow(
                                                    icon:
                                                        Icons.edit_off_outlined,
                                                    text:
                                                        'Items cannot be edited after placing the order.',
                                                  ),

                                                  SizedBox(height: 12),

                                                  _CheckoutInfoRow(
                                                    icon: Icons
                                                        .local_shipping_outlined,
                                                    text:
                                                        'Delivery details will be confirmed next.',
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 22),

                                            // ======================================
                                            // ACTION BUTTONS
                                            // ======================================
                                            Row(
                                              children: [
                                                // ----------------------------------
                                                // REVIEW CART
                                                // ----------------------------------
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 14,
                                                          ),
                                                      side: BorderSide(
                                                        color: AppColors.border
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(false);
                                                    },
                                                    child: const Text(
                                                      'Review Cart',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // ----------------------------------
                                                // CONTINUE
                                                // ----------------------------------
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 0,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 14,
                                                          ),
                                                      backgroundColor:
                                                          AppColors.primary,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        dialogContext,
                                                      ).pop(true);
                                                    },
                                                    child: const Text(
                                                      'Continue',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                            // ====================================================
                            // USER CANCELLED
                            // ====================================================
                            if (shouldProceed != true) {
                              return;
                            }

                            if (!context.mounted) return;

                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                      return const CheckoutScreen();
                                    },

                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeOutCubic;

                                      final curvedAnimation = CurvedAnimation(
                                        parent: animation,
                                        curve: curve,
                                      );

                                      final slideAnimation = Tween<Offset>(
                                        begin: begin,
                                        end: end,
                                      ).animate(curvedAnimation);

                                      final fadeAnimation = Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ).animate(curvedAnimation);

                                      return FadeTransition(
                                        opacity: fadeAnimation,
                                        child: SlideTransition(
                                          position: slideAnimation,
                                          child: child,
                                        ),
                                      );
                                    },

                                transitionDuration: const Duration(
                                  milliseconds: 320,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.1,
                                ),
                              ),

                              SizedBox(width: 8),

                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 70,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like you haven\'t added any delicious smoothies or snacks yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(),
                    ),
                    (route) => false, // Clears all screens in the stack
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text(
                  'Explore Menu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_drink_rounded,
          size: 24,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 32,
          height: 36,
          child: Center(
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _CheckoutInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CheckoutInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
