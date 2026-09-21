import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

import '../../checkout/screens/checkout_screen.dart';

import '../../../widgets/main_navigation_screen.dart';

import '../services/cart_service.dart';

import '../widgets/cart_checkout_dialog.dart';
import '../widgets/cart_clear_dialog.dart';
import '../widgets/cart_empty_state.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_order_summary.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    super.key,
  });

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {
  final CartService _cartService =
      CartService();

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _cartService.addListener(
      _onCartChanged,
    );
  }

  @override
  void dispose() {
    _cartService.removeListener(
      _onCartChanged,
    );

    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // =============================================================
  // CLEAR CART
  // =============================================================

  Future<void> _confirmClearCart() async {
    final bool shouldClear =
        await showCartClearDialog(
      context,
    );

    if (!shouldClear) return;

    _cartService.clearCart();
  }

  // =============================================================
  // CHECKOUT
  // =============================================================

  Future<void>
      _showCheckoutConfirmation() async {
    final bool shouldProceed =
        await showCartCheckoutDialog(
      context,
    );

    if (!shouldProceed || !mounted) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const CheckoutScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final Animation<double>
              curvedAnimation =
              CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          final Animation<Offset>
              slideAnimation =
              Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          final Animation<double>
              fadeAnimation =
              Tween<double>(
            begin: 0,
            end: 1,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        transitionDuration:
            const Duration(
          milliseconds: 320,
        ),
      ),
    );
  }

  // =============================================================
  // EXPLORE MENU
  // =============================================================

  void _exploreMenu() {
    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const MainNavigationScreen(),
      ),
      (route) => false,
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final cartItems =
        _cartService.items;

    final int totalCount =
        cartItems.fold<int>(
      0,
      (sum, item) =>
          sum + item.quantity,
    );

    final bool hasItems =
        cartItems.isNotEmpty;

    return Scaffold(
      backgroundColor:
          AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =============================================
            // PAGE HEADER
            // =============================================

            CartHeader(
              totalCount: totalCount,
              hasItems: hasItems,
              onClear:
                  _confirmClearCart,
            ),

            // =============================================
            // CONTENT
            // =============================================

            Expanded(
              child: hasItems
                  ? ListView.separated(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        AppConstants
                            .defaultPadding,
                        4,
                        AppConstants
                            .defaultPadding,
                        24,
                      ),
                      physics:
                          const BouncingScrollPhysics(),
                      itemCount:
                          cartItems.length,
                      separatorBuilder:
                          (_, _) =>
                              const SizedBox(
                        height: 11,
                      ),
                      itemBuilder:
                          (context, index) {
                        final item =
                            cartItems[
                                index];

                        return CartItemCard(
                          item: item,
                          cartService:
                              _cartService,
                        );
                      },
                    )
                  : CartEmptyState(
                      onExplore:
                          _exploreMenu,
                    ),
            ),

            // =============================================
            // ORDER SUMMARY
            // =============================================

            if (hasItems)
              CartOrderSummary(
                totalCount:
                    totalCount,
                subtotal:
                    _cartService
                        .subtotal,
                onCheckout:
                    _showCheckoutConfirmation,
              ),
          ],
        ),
      ),
    );
  }
}