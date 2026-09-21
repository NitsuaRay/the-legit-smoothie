import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_contact_card.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_header.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_order_notice.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_order_summary.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_order_type_selector.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_overview.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_place_order_button.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_section_header.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkoutScreen/checkout_security_message.dart';
import 'package:the_legit_smoothie/features/profile/screens/profile_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../../cart/services/cart_service.dart';
import 'order_receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final CartService _cartService = CartService();

  String _orderType = 'delivery';

  bool _isSubmitting = false;
  bool _isLoadingProfile = true;

  static const double _deliveryFeeAmount = 45.00;

  // =============================================================
  // GETTERS
  // =============================================================

  double get _subtotal {
    return _cartService.subtotal;
  }

  double get _discountedSubtotal {
    return _cartService.discountedSubtotal;
  }

  double get _deliveryFee {
    return _orderType == 'delivery' ? _deliveryFeeAmount : 0.0;
  }

  double get _grandTotal {
    return _discountedSubtotal + _deliveryFee;
  }

  int get _totalItemCount {
    return _cartService.items.fold(0, (sum, item) => sum + item.quantity);
  }

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _cartService.addListener(_onCartChanged);

    _loadSavedProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_cartService.items.isNotEmpty) {
        await _cartService.calculatePromotion();
      }
    });
  }

  void _onCartChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);

    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // =============================================================
  // LOAD SAVED PROFILE
  // =============================================================

  Future<void> _loadSavedProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }

      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select('phone_number, default_address')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final String phoneNumber =
            data['phone_number']?.toString().trim() ?? '';

        final String address = data['default_address']?.toString().trim() ?? '';

        setState(() {
          // Always refresh these values from Profile.
          // This is important after returning from editing Profile.
          _contactController.text = phoneNumber;
          _addressController.text = address;
        });
      }
    } catch (e) {
      debugPrint('Error auto-loading user profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  // =============================================================
  // OPEN PROFILE
  // =============================================================

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(showBackButton: true),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isLoadingProfile = true;
    });

    await _loadSavedProfile();
  }

  // =============================================================
  // CHANGE ORDER TYPE
  // =============================================================

  void _changeOrderType(String value) {
    if (_orderType == value) {
      return;
    }

    setState(() {
      _orderType = value;
    });
  }

  // =============================================================
  // SUBMIT ORDER
  // =============================================================

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage(
        'You need to be signed in to place an order.',
        isError: true,
      );
      return;
    }

    if (_cartService.items.isEmpty) {
      _showMessage('Your cart is empty.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ==========================================================
      // RE-CALCULATE PROMOTION BEFORE CHECKOUT
      // ==========================================================
      //
      // This is important because calculate_best_promotion()
      // now checks max_uses_per_user against promotion_redemptions.
      //
      // If the customer already used Triple Drink Combo,
      // it will no longer be returned here.
      // ==========================================================

      await _cartService.calculatePromotion();

      // Make sure the cart was not emptied while calculating.
      if (_cartService.items.isEmpty) {
        throw Exception('Your cart is empty.');
      }

      // ==========================================================
      // SNAPSHOT VALUES
      // ==========================================================

      final double originalSubtotalSnapshot = _cartService.subtotal;

      final promotionSnapshot = _cartService.appliedPromotion;

      final double discountSnapshot = _cartService.discountAmount;

      final double subtotalSnapshot = _cartService.discountedSubtotal;

      final double deliveryFeeSnapshot = _deliveryFee;

      final double grandTotalSnapshot = subtotalSnapshot + deliveryFeeSnapshot;

      final String contactSnapshot = _contactController.text.trim();

      final String? addressSnapshot = _orderType == 'delivery'
          ? _addressController.text.trim()
          : null;

      final String notesSnapshot = _notesController.text.trim();

      // ==========================================================
      // SNAPSHOT CART ITEMS
      // ==========================================================
      //
      // Build these before clearing the cart.
      // ==========================================================

      final orderItemsData = _cartService.items.map((item) {
        return {
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'selected_options': item.selectedOptions,
        };
      }).toList();

      // ==========================================================
      // UPDATE USER PROFILE
      // ==========================================================

      await supabase.from('profiles').upsert({
        'id': user.id,
        'phone_number': contactSnapshot,
        'default_address': _orderType == 'delivery' ? addressSnapshot : null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // ==========================================================
      // CREATE ORDER
      // ==========================================================

      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,

            'order_type': _orderType,

            'delivery_address': _orderType == 'delivery'
                ? addressSnapshot
                : null,

            'contact_number': contactSnapshot,

            'notes': notesSnapshot,

            // ----------------------------------------------------
            // TOTALS
            // ----------------------------------------------------

            // Your current schema stores the already-discounted
            // subtotal here.
            'subtotal': subtotalSnapshot,

            'delivery_fee': deliveryFeeSnapshot,

            'total_price': grandTotalSnapshot,

            // ----------------------------------------------------
            // PROMOTION
            // ----------------------------------------------------
            'discount_amount': discountSnapshot,

            'promotion_id': promotionSnapshot?.id,

            'promotion_title': promotionSnapshot?.title,

            'promotion_snapshot': promotionSnapshot?.snapshot,

            'status': 'pending',
          })
          .select('id')
          .single();

      final String orderId = orderResponse['id'].toString();

      // ==========================================================
      // CREATE ORDER ITEMS
      // ==========================================================

      final orderItemsWithOrderId = orderItemsData.map((item) {
        return {...item, 'order_id': orderId};
      }).toList();

      await supabase.from('order_items').insert(orderItemsWithOrderId);

      // ==========================================================
      // CREATE PROMOTION REDEMPTION
      // ==========================================================
      //
      // Only create a redemption when:
      //
      // 1. A promotion was actually applied.
      // 2. The discount is greater than zero.
      //
      // This row is what max_uses_per_user uses to determine
      // whether this customer has already redeemed the promotion.
      // ==========================================================

      if (promotionSnapshot != null && discountSnapshot > 0) {
        await supabase.from('promotion_redemptions').insert({
          'promotion_id': promotionSnapshot.id,

          'order_id': orderId,

          'user_id': user.id,

          'promotion_title': promotionSnapshot.title,

          'discount_amount': discountSnapshot,

          'promotion_snapshot': promotionSnapshot.snapshot,
        });
      }

      // ==========================================================
      // DEBUG
      // ==========================================================

      debugPrint('Order created: $orderId');

      if (promotionSnapshot != null && discountSnapshot > 0) {
        debugPrint(
          'Promotion redeemed: '
          '${promotionSnapshot.title}',
        );

        debugPrint(
          'Promotion ID: '
          '${promotionSnapshot.id}',
        );

        debugPrint(
          'Discount: '
          '$discountSnapshot',
        );
      } else {
        debugPrint('Order has no promotion.');
      }

      // ==========================================================
      // CLEAR CART
      // ==========================================================

      _cartService.clearCart();

      if (!mounted) return;

      // ==========================================================
      // RECEIPT
      // ==========================================================

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderReceiptScreen(
            orderId: orderId,

            orderType: _orderType,

            contactNumber: contactSnapshot,

            deliveryAddress: addressSnapshot,

            notes: notesSnapshot,

            originalSubtotal: originalSubtotalSnapshot,

            discountAmount: discountSnapshot,

            promotionTitle: promotionSnapshot?.title,

            subtotal: subtotalSnapshot,

            deliveryFee: deliveryFeeSnapshot,

            grandTotal: grandTotalSnapshot,

            items: orderItemsWithOrderId,

            orderDate: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Checkout error: $e');

      if (!mounted) return;

      _showMessage('Failed to submit order: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================================================
            // HEADER
            // =========================================================
            CheckoutHeader(
              onBack: () {
                Navigator.of(context).pop();
              },
            ),

            // =========================================================
            // CONTENT
            // =========================================================
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    6,
                    AppConstants.defaultPadding,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===============================================
                      // OVERVIEW
                      // ===============================================
                      CheckoutOverview(
                        totalItemCount: _totalItemCount,
                        orderType: _orderType,
                        deliveryFee: _deliveryFee,
                        grandTotal: _grandTotal,
                      ),

                      const SizedBox(height: 28),

                      // ===============================================
                      // FULFILLMENT
                      // ===============================================
                      const CheckoutSectionHeader(
                        eyebrow: 'FULFILLMENT',
                        icon: Icons.local_shipping_outlined,
                        title: 'How would you like it?',
                        subtitle:
                            'Choose delivery to your address or pick up your order from the store.',
                      ),

                      const SizedBox(height: 14),

                      CheckoutOrderTypeSelector(
                        value: _orderType,
                        onChanged: _changeOrderType,
                      ),

                      const SizedBox(height: 28),

                      // ===============================================
                      // CUSTOMER DETAILS
                      // ===============================================
                      const CheckoutSectionHeader(
                        eyebrow: 'YOUR DETAILS',
                        icon: Icons.person_outline_rounded,
                        title: 'Contact & Delivery',
                        subtitle:
                            'We’ll use these details to contact you and complete your order.',
                      ),

                      const SizedBox(height: 14),

                      CheckoutContactCard(
                        contactController: _contactController,
                        addressController: _addressController,
                        notesController: _notesController,
                        orderType: _orderType,
                        isLoading: _isLoadingProfile,
                        onEditProfile: _openProfile,
                      ),

                      const SizedBox(height: 28),

                      // ===============================================
                      // SUMMARY
                      // ===============================================
                      const CheckoutSectionHeader(
                        eyebrow: 'ORDER TOTAL',
                        icon: Icons.receipt_long_outlined,
                        title: 'Order Summary',
                        subtitle:
                            'Review your charges before placing your order.',
                      ),

                      const SizedBox(height: 14),

                      CheckoutOrderSummary(
                        totalItemCount: _totalItemCount,
                        orderType: _orderType,
                        subtotal: _subtotal,
                        deliveryFee: _deliveryFee,
                        grandTotal: _grandTotal,
                        promotion: _cartService.appliedPromotion,
                        isCalculatingPromotion:
                            _cartService.isCalculatingPromotion,
                      ),

                      const SizedBox(height: 17),

                      // ===============================================
                      // NOTICE
                      // ===============================================
                      CheckoutOrderNotice(orderType: _orderType),

                      const SizedBox(height: 17),

                      // ===============================================
                      // PLACE ORDER
                      // ===============================================
                      CheckoutPlaceOrderButton(
                        isSubmitting: _isSubmitting,
                        grandTotal: _grandTotal,
                        onPressed: _submitOrder,
                      ),

                      const SizedBox(height: 12),

                      const CheckoutSecurityMessage(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
