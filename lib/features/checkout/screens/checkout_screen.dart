import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkout_widgets.dart.dart';
import 'package:the_legit_smoothie/features/profile/screens/profile_screen.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';
import '../../cart/services/cart_service.dart';
import 'order_receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _contactController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  final CartService _cartService = CartService();

  String _orderType = 'delivery';

  bool _isSubmitting = false;
  bool _isLoadingProfile = true;

  static const double _deliveryFeeAmount = 45.00;

  // =============================================================
  // GETTERS
  // =============================================================

  double get _deliveryFee {
    return _orderType == 'delivery'
        ? _deliveryFeeAmount
        : 0.0;
  }

  double get _grandTotal {
    return _cartService.subtotal + _deliveryFee;
  }

  int get _totalItemCount {
    return _cartService.items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  bool get _hasContact {
    return _contactController.text.trim().isNotEmpty;
  }

  bool get _hasAddress {
    return _addressController.text.trim().isNotEmpty;
  }

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  @override
  void dispose() {
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
          .select(
            'phone_number, default_address',
          )
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      if (data != null) {
        final String phoneNumber =
            data['phone_number']?.toString().trim() ?? '';

        final String address =
            data['default_address']?.toString().trim() ?? '';

        setState(() {
          // Always refresh these values from Profile.
          // This is important after returning from editing Profile.
          _contactController.text = phoneNumber;
          _addressController.text = address;
        });
      }
    } catch (e) {
      debugPrint(
        'Error auto-loading user profile: $e',
      );
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
        builder: (_) => const ProfileScreen(
          showBackButton: true,
        ),
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

  void _changeOrderType(
    String value,
  ) {
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
      return;
    }

    if (_cartService.items.isEmpty) {
      _showMessage(
        'Your cart is empty.',
      );

      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ==========================================================
      // SNAPSHOT VALUES
      // ==========================================================

      final double subtotalSnapshot =
          _cartService.subtotal;

      final double deliveryFeeSnapshot =
          _deliveryFee;

      final double grandTotalSnapshot =
          _grandTotal;

      final String contactSnapshot =
          _contactController.text.trim();

      final String? addressSnapshot =
          _orderType == 'delivery'
              ? _addressController.text.trim()
              : null;

      final String notesSnapshot =
          _notesController.text.trim();

      // ==========================================================
      // UPDATE USER PROFILE
      // ==========================================================

      await supabase.from('profiles').upsert({
        'id': user.id,
        'phone_number': contactSnapshot,
        'default_address':
            _orderType == 'delivery'
                ? addressSnapshot
                : null,
        'updated_at':
            DateTime.now().toIso8601String(),
      });

      // ==========================================================
      // CREATE ORDER
      // ==========================================================

      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'order_type': _orderType,
            'delivery_address': addressSnapshot,
            'contact_number': contactSnapshot,
            'notes': notesSnapshot,
            'subtotal': subtotalSnapshot,
            'delivery_fee': deliveryFeeSnapshot,
            'total_price': grandTotalSnapshot,
            'status': 'pending',
          })
          .select('id')
          .single();

      final String orderId =
          orderResponse['id'].toString();

      // ==========================================================
      // CREATE ORDER ITEMS
      // ==========================================================

      final orderItemsData =
          _cartService.items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'selected_options':
              item.selectedOptions,
        };
      }).toList();

      await supabase
          .from('order_items')
          .insert(orderItemsData);

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
            subtotal: subtotalSnapshot,
            deliveryFee:
                deliveryFeeSnapshot,
            grandTotal: grandTotalSnapshot,
            items: orderItemsData,
            orderDate: DateTime.now(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to submit order: $e',
        isError: true,
      );
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

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: isError
              ? AppColors.error
              : AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
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

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: MainAppBar(
        showLogo: false,
        showBackButton: true,
        showStoreStatus: false,
        titleWidget: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.border.withValues(
                    alpha: 0.32,
                  ),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checkout',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.45,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Review and place your order',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            20,
            AppConstants.defaultPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ===================================================
              // CHECKOUT OVERVIEW
              // ===================================================

              _buildCheckoutOverview(),

              const SizedBox(height: 30),

              // ===================================================
              // ORDER TYPE
              // ===================================================

              const CheckoutSectionHeader(
                eyebrow: 'FULFILLMENT',
                icon:
                    Icons.local_shipping_outlined,
                title:
                    'How would you like it?',
                subtitle:
                    'Choose delivery to your address or pick up your order from the store.',
              ),

              const SizedBox(height: 14),

              _buildOrderTypeSelector(),

              const SizedBox(height: 30),

              // ===================================================
              // CONTACT
              // ===================================================

              const CheckoutSectionHeader(
                eyebrow: 'YOUR DETAILS',
                icon:
                    Icons.person_outline_rounded,
                title: 'Contact & Delivery',
                subtitle:
                    'We’ll use these details to contact you and complete your order.',
              ),

              const SizedBox(height: 14),

              _buildContactCard(),

              const SizedBox(height: 30),

              // ===================================================
              // ORDER SUMMARY
              // ===================================================

              const CheckoutSectionHeader(
                eyebrow: 'ORDER TOTAL',
                icon:
                    Icons.receipt_long_outlined,
                title: 'Order Summary',
                subtitle:
                    'Review your charges before placing your order.',
              ),

              const SizedBox(height: 14),

              _buildOrderSummary(),

              const SizedBox(height: 18),

              // ===================================================
              // ORDER NOTICE
              // ===================================================

              _buildOrderNotice(),

              const SizedBox(height: 18),

              // ===================================================
              // PLACE ORDER
              // ===================================================

              _buildPlaceOrderButton(),

              const SizedBox(height: 12),

              // ===================================================
              // SECURITY MESSAGE
              // ===================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .verified_user_outlined,
                    size: 13,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.50,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    'Your order details are securely submitted',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w500,
                      color: AppColors
                          .textSecondary
                          .withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // CHECKOUT OVERVIEW
  // =============================================================

  Widget _buildCheckoutOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalItemCount '
                  '${_totalItemCount == 1 ? 'item' : 'items'} in your order',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.25,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _orderType == 'delivery'
                      ? 'Delivery • Fee ${AppHelpers.formatCurrency(_deliveryFee)}'
                      : 'Store Pickup • No delivery fee',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white
                        .withValues(
                      alpha: 0.65,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                AppHelpers.formatCurrency(
                  _grandTotal,
                ),
                style: const TextStyle(
                  fontSize: 19,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ORDER TYPE SELECTOR
  // =============================================================

  Widget _buildOrderTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.32,
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
      child: Row(
        children: [
          Expanded(
            child: OrderTypeTab(
              label: 'Delivery',
              icon:
                  Icons.delivery_dining_outlined,
              value: 'delivery',
              groupValue: _orderType,
              onTap: _changeOrderType,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: OrderTypeTab(
              label: 'Store Pickup',
              icon: Icons.storefront_outlined,
              value: 'pickup',
              groupValue: _orderType,
              onTap: _changeOrderType,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // CONTACT CARD
  // =============================================================

  Widget _buildContactCard() {
    return CheckoutCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =======================================================
          // CARD HEADER
          // =======================================================

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saved Information',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: -0.2,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Managed from your profile',
                      style: TextStyle(
                        fontSize: 9,
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
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _openProfile,
                  borderRadius:
                      BorderRadius.circular(11),
                  child: Ink(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(
                        11,
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
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors
                              .textPrimary,
                        ),

                        SizedBox(width: 5),

                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w800,
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

          const CheckoutDivider(),

          // =======================================================
          // PROFILE LOADING
          // =======================================================

          if (_isLoadingProfile)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else ...[
            // =====================================================
            // CONTACT NUMBER
            // =====================================================

            TextFormField(
              controller:
                  _contactController,
              readOnly: true,
              showCursor: false,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color:
                    AppColors.textPrimary,
              ),
              decoration:
                  buildCheckoutInputDecoration(
                label: 'Contact Number',
                hint:
                    'No contact number saved',
                icon: Icons.phone_outlined,
                suffixIcon: _hasContact
                    ? const Icon(
                        Icons
                            .check_circle_rounded,
                        size: 18,
                        color:
                            AppColors.success,
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Please add a contact number in your profile';
                }

                return null;
              },
            ),

            // =====================================================
            // ADDRESS
            // =====================================================

            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 250,
              ),
              switchInCurve:
                  Curves.easeOutCubic,
              switchOutCurve:
                  Curves.easeInCubic,
              child:
                  _orderType == 'delivery'
                      ? Padding(
                          key: const ValueKey(
                            'delivery-address',
                          ),
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 13,
                          ),
                          child:
                              TextFormField(
                            controller:
                                _addressController,
                            readOnly: true,
                            showCursor: false,
                            maxLines: 2,
                            style:
                                const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight:
                                  FontWeight.w700,
                              color: AppColors
                                  .textPrimary,
                            ),
                            decoration:
                                buildCheckoutInputDecoration(
                              label:
                                  'Delivery Address',
                              hint:
                                  'No delivery address saved',
                              icon: Icons
                                  .location_on_outlined,
                              suffixIcon:
                                  _hasAddress
                                      ? const Icon(
                                          Icons
                                              .check_circle_rounded,
                                          size:
                                              18,
                                          color:
                                              AppColors.success,
                                        )
                                      : null,
                            ),
                            validator:
                                (value) {
                              if (_orderType ==
                                      'delivery' &&
                                  (value ==
                                          null ||
                                      value
                                          .trim()
                                          .isEmpty)) {
                                return 'Please add a delivery address in your profile';
                              }

                              return null;
                            },
                          ),
                        )
                      : const SizedBox
                          .shrink(
                          key: ValueKey(
                            'pickup-address',
                          ),
                        ),
            ),

            const SizedBox(height: 16),

            // =====================================================
            // ORDER NOTES HEADER
            // =====================================================

            Row(
              children: [
                const Text(
                  'Order Instructions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const Spacer(),

                CheckoutInfoBadge(
                  label: 'Optional',
                  icon:
                      Icons.edit_note_outlined,
                  color: AppColors
                      .textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 9),

            // =====================================================
            // NOTES
            // =====================================================

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              minLines: 2,
              textCapitalization:
                  TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color:
                    AppColors.textPrimary,
              ),
              decoration:
                  buildCheckoutInputDecoration(
                label: 'Notes / Instructions',
                hint:
                    'e.g. Less sugar, call upon arrival',
                icon:
                    Icons.note_alt_outlined,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // ORDER SUMMARY
  // =============================================================

  Widget _buildOrderSummary() {
    return CheckoutCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // =======================================================
          // ITEMS
          // =======================================================

          SummaryRowItem(
            icon:
                Icons.shopping_bag_outlined,
            label: 'Subtotal',
            subtitle:
                '$_totalItemCount ${_totalItemCount == 1 ? 'item' : 'items'} in your cart',
            value:
                AppHelpers.formatCurrency(
              _cartService.subtotal,
            ),
          ),

          const CheckoutDivider(),

          // =======================================================
          // DELIVERY
          // =======================================================

          SummaryRowItem(
            icon:
                _orderType == 'delivery'
                    ? Icons
                        .local_shipping_outlined
                    : Icons
                        .storefront_outlined,
            label: _orderType == 'delivery'
                ? 'Delivery Fee'
                : 'Store Pickup',
            subtitle:
                _orderType == 'delivery'
                    ? 'Standard local delivery'
                    : 'Collect your order from the store',
            value:
                _orderType == 'delivery'
                    ? AppHelpers.formatCurrency(
                        _deliveryFee,
                      )
                    : 'FREE',
            valueColor:
                _orderType == 'pickup'
                    ? AppColors.success
                    : AppColors.textPrimary,
          ),

          const CheckoutDivider(
            verticalPadding: 17,
          ),

          // =======================================================
          // TOTAL
          // =======================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: -0.3,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Final amount for this order',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w500,
                        color: AppColors
                            .textSecondary
                            .withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Text(
                AppHelpers.formatCurrency(
                  _grandTotal,
                ),
                style: const TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: -0.9,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ORDER NOTICE
  // =============================================================

  Widget _buildOrderNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Before placing your order',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Please make sure your contact information, '
                  '${_orderType == 'delivery' ? 'delivery address, ' : ''}'
                  'items, and instructions are correct.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.4,
                    fontWeight:
                        FontWeight.w500,
                    color: AppColors
                        .textSecondary
                        .withValues(
                      alpha: 0.70,
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

  // =============================================================
  // PLACE ORDER BUTTON
  // =============================================================

  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed:
            _isSubmitting
                ? null
                : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.textPrimary,
          disabledBackgroundColor:
              AppColors.textPrimary.withValues(
            alpha: 0.50,
          ),
          foregroundColor: Colors.white,
          disabledForegroundColor:
              Colors.white.withValues(
            alpha: 0.80,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 21,
                height: 21,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons
                        .check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 9),

                  Flexible(
                    child: Text(
                      'Place Order  •  '
                      '${AppHelpers.formatCurrency(_grandTotal)}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: -0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 9),

                  const Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 17,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}