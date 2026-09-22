import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:uuid/uuid.dart';

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

  final Uuid _uuid = const Uuid();

  String? _checkoutRequestId;

  String _orderType = 'delivery';

  bool _isSubmitting = false;
  bool _isLoadingProfile = true;

  static const double _deliveryFeeAmount = 45.00;

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

  void _changeOrderType(String value) {
    if (_orderType == value) {
      return;
    }

    setState(() {
      _orderType = value;
    });
  }

  Future<void> _submitOrder() async {
    // =============================================================
    // PREVENT DOUBLE TAP
    // =============================================================

    if (_isSubmitting) {
      return;
    }

    // =============================================================
    // VALIDATE FORM
    // =============================================================

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // =============================================================
    // USER
    // =============================================================

    final user = supabase.auth.currentUser;

    if (user == null) {
      _showMessage(
        'You need to be signed in to place an order.',
        isError: true,
      );

      return;
    }

    // =============================================================
    // CART
    // =============================================================

    if (_cartService.items.isEmpty) {
      _showMessage('Your cart is empty.', isError: true);

      return;
    }

    // =============================================================
    // REQUEST ID
    // =============================================================
    //
    // IMPORTANT:
    //
    // Generate only when there is no existing checkout request.
    //
    // If the internet disconnects and the customer retries,
    // this SAME ID is sent again.
    //
    // That prevents duplicate orders.
    // =============================================================

    _checkoutRequestId ??= _uuid.v4();

    final String requestId = _checkoutRequestId!;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // ===========================================================
      // CONTACT SNAPSHOT
      // ===========================================================

      final String contactSnapshot = _contactController.text.trim();

      final String? addressSnapshot = _orderType == 'delivery'
          ? _addressController.text.trim()
          : null;

      final String notesSnapshot = _notesController.text.trim();

      // ===========================================================
      // CART PAYLOAD
      // ===========================================================
      //
      // SAME FORMAT AS PromotionService:
      //
      // {
      //   product_id,
      //   quantity,
      //   selected_option_ids
      // }
      //
      // ===========================================================

      final List<Map<String, dynamic>> cartPayload = _cartService.items.map((
        item,
      ) {
        final List<String> optionIds = [];

        for (final option in item.selectedOptions) {
          final dynamic rawId = option['id'] ?? option['option_id'];

          if (rawId == null) {
            continue;
          }

          final String id = rawId.toString().trim();

          if (id.isNotEmpty) {
            optionIds.add(id);
          }
        }

        return {
          'product_id': item.product.id,

          'quantity': item.quantity,

          'selected_option_ids': optionIds,
        };
      }).toList();

      // ===========================================================
      // SINGLE TRANSACTIONAL CHECKOUT RPC
      // ===========================================================

      final dynamic response = await supabase.rpc(
        'create_order',
        params: {
          'p_checkout_request_id': requestId,

          'p_order_type': _orderType,

          'p_contact_number': contactSnapshot,

          'p_delivery_address': addressSnapshot,

          'p_notes': notesSnapshot,

          'p_cart': cartPayload,
        },
      );

      if (response == null) {
        throw Exception('The server did not return an order.');
      }

      final Map<String, dynamic> result = Map<String, dynamic>.from(
        response as Map,
      );

      // ===========================================================
      // SERVER VALUES
      // ===========================================================
      //
      // Do NOT use Flutter totals as the authoritative receipt.
      //
      // The database has recalculated everything.
      // ===========================================================

      double toDouble(dynamic value, {double fallback = 0}) {
        if (value == null) {
          return fallback;
        }

        if (value is num) {
          return value.toDouble();
        }

        return double.tryParse(value.toString()) ?? fallback;
      }

      final String orderId = result['order_id'].toString();

      final double originalSubtotal = toDouble(
        result['original_subtotal'],
        fallback: _cartService.subtotal,
      );

      final double subtotal = toDouble(result['subtotal']);

      final double deliveryFee = toDouble(result['delivery_fee']);

      final double grandTotal = toDouble(result['total_price']);

      final double discountAmount = toDouble(result['discount_amount']);

      final String? promotionTitle = result['promotion_title']?.toString();

      // ===========================================================
      // RECEIPT ITEMS
      // ===========================================================

      final List<Map<String, dynamic>> receiptItems = [];

      final dynamic rawItems = result['items'];

      if (rawItems is List) {
        for (final dynamic item in rawItems) {
          if (item is Map) {
            receiptItems.add(Map<String, dynamic>.from(item));
          }
        }
      } else {
        // A successful idempotent retry may return an existing
        // order without the item payload depending on the RPC
        // response path.
        //
        // Load its authoritative items.

        final List<dynamic> existingItems = await supabase
            .from('order_items')
            .select(
              'id, order_id, product_id, '
              'product_name, quantity, '
              'unit_price, selected_options, '
              'total_price',
            )
            .eq('order_id', orderId);

        for (final dynamic item in existingItems) {
          if (item is Map) {
            receiptItems.add(Map<String, dynamic>.from(item));
          }
        }
      }

      _cartService.clearCart();

      if (!mounted) {
        return;
      }

      _checkoutRequestId = null;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderReceiptScreen(
            orderId: orderId,

            orderType: _orderType,

            contactNumber: contactSnapshot,

            deliveryAddress: addressSnapshot,

            notes: notesSnapshot,

            originalSubtotal: originalSubtotal,

            discountAmount: discountAmount,

            promotionTitle: promotionTitle,

            subtotal: subtotal,

            deliveryFee: deliveryFee,

            grandTotal: grandTotal,

            items: receiptItems,

            orderDate: DateTime.now(),
          ),
        ),
      );
    } on PostgrestException catch (error) {

      if (!mounted) {
        return;
      }


      _showMessage(error.message, isError: true);
    } catch (error) {

      if (!mounted) {
        return;
      }

      // Again:
      // KEEP _checkoutRequestId for retry.

      _showMessage(
        'We could not confirm your order. '
        'Check your connection and try again.',
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
