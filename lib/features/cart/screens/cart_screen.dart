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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _cartService.clearCart();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: cartItems.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: AppColors.error,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) {
                          _cartService.removeItem(item.id);
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
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
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.border.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child:
                                          item.product.imageUrl != null &&
                                              item.product.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              item.product.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildPlaceholderImage(),
                                            )
                                          : _buildPlaceholderImage(),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Item Specs & Price
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Custom Option Pills
                                        if (item
                                            .selectedOptions
                                            .isNotEmpty) ...[
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: item.selectedOptions.map((
                                              opt,
                                            ) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.background,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: AppColors.border
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                ),
                                                child: Text(
                                                  opt['name'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors
                                                        .textSecondary
                                                        .withValues(alpha: 0.9),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 8),
                                        ],

                                        Text(
                                          AppHelpers.formatCurrency(
                                            item.totalPrice,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Controls
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => _cartService
                                                  .decrementQuantity(item.id),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.remove_rounded,
                                                  size: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6.0,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _cartService
                                                  .incrementQuantity(item.id),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  size: 16,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              ProductDetailModal.show(
                                                context,
                                                item.product,
                                                cartItem: item,
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            ' • ',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => _cartService
                                                .removeItem(item.id),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'Remove',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.error,
                                                ),
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
