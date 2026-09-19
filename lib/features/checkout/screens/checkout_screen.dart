import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/checkout/widgets/checkout_widgets.dart.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';
import '../../cart/services/cart_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  final CartService _cartService = CartService();

  String _orderType = 'delivery'; // 'delivery' or 'pickup'
  bool _isSubmitting = false;

  static const double _deliveryFeeAmount = 45.00;

  double get _deliveryFee =>
      _orderType == 'delivery' ? _deliveryFeeAmount : 0.0;
  double get _grandTotal => _cartService.subtotal + _deliveryFee;

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

  Future<void> _loadSavedProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select('phone_number, default_address')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          if (data['phone_number'] != null && _contactController.text.isEmpty) {
            _contactController.text = data['phone_number'];
          }
          if (data['default_address'] != null &&
              _addressController.text.isEmpty) {
            _addressController.text = data['default_address'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error auto-loading user profile: $e');
    }
  }

  // Update _submitOrder method to save current details to profile:
  Future<void> _submitOrder() async {
    if (_orderType == 'delivery' && !_formKey.currentState!.validate()) {
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      // 0. Update default address & phone in profiles table for next time
      await supabase.from('profiles').upsert({
        'id': user.id,
        'phone_number': _contactController.text.trim(),
        'default_address': _orderType == 'delivery'
            ? _addressController.text.trim()
            : null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 1. Insert Master Order record into Supabase
      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'order_type': _orderType,
            'delivery_address': _orderType == 'delivery'
                ? _addressController.text.trim()
                : null,
            'contact_number': _contactController.text.trim(),
            'notes': _notesController.text.trim(),
            'subtotal': _cartService.subtotal,
            'delivery_fee': _deliveryFee,
            'total_price': _grandTotal,
            'status': 'pending',
          })
          .select('id')
          .single();

      final String orderId = orderResponse['id'];

      // 2. Prepare Order Items
      final orderItemsData = _cartService.items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
          'selected_options': item.selectedOptions,
        };
      }).toList();

      // 3. Insert Order Items
      await supabase.from('order_items').insert(orderItemsData);

      // 4. Clear cart
      _cartService.clearCart();

      if (!mounted) return;

      // Show Modern Premium Dialog Widget from checkout_widgets.dart
      await OrderSuccessDialog.show(
        context: context,
        orderId: orderId,
        onDismiss: () {
          Navigator.of(context).pop();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        showLogo: false,
        showBackButton: true,
        titleWidget: Row(
          children: [
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
                Icons.receipt_long_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.textPrimary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Checkout',
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
                    'Complete your order details',
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CheckoutSectionHeader(
                title: 'Order Type',
                subtitle: 'Select how you want to receive your smoothies',
              ),
              const SizedBox(height: 12),

              // Segmented Switcher using OrderTypeTab widget
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OrderTypeTab(
                        label: 'Delivery',
                        icon: Icons.delivery_dining_rounded,
                        value: 'delivery',
                        groupValue: _orderType,
                        onTap: (val) => setState(() => _orderType = val),
                      ),
                    ),
                    Expanded(
                      child: OrderTypeTab(
                        label: 'Store Pickup',
                        icon: Icons.storefront_rounded,
                        value: 'pickup',
                        groupValue: _orderType,
                        onTap: (val) => setState(() => _orderType = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const CheckoutSectionHeader(
                title: 'Contact & Delivery',
                subtitle: 'Enter your location and contact details',
              ),
              const SizedBox(height: 12),

              // Form Card Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: buildCheckoutInputDecoration(
                        label: 'Contact Number',
                        hint: 'e.g., 09123456789',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contact number for updates';
                        }
                        return null;
                      },
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _orderType == 'delivery'
                          ? Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: buildCheckoutInputDecoration(
                                  label: 'Delivery Address',
                                  hint: 'Street, Barangay, City / Landmark',
                                  icon: Icons.location_on_outlined,
                                ),
                                validator: (value) {
                                  if (_orderType == 'delivery' &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Please provide complete delivery address';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: buildCheckoutInputDecoration(
                        label: 'Notes / Instructions',
                        hint: 'e.g., Less sugar, call upon arrival',
                        icon: Icons.note_alt_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const CheckoutSectionHeader(
                title: 'Payment Summary',
                subtitle: 'Review your total costs',
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SummaryRowItem(
                      label: 'Subtotal',
                      value: AppHelpers.formatCurrency(200.00),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    SummaryRowItem(
                      label: 'Delivery Fee',
                      value: _orderType == 'delivery'
                          ? AppHelpers.formatCurrency(_deliveryFee)
                          : 'FREE (Pickup)',
                      valueColor: _orderType == 'pickup'
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrency(_grandTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // CTA Place Order Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondaryDark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Place Order • ${AppHelpers.formatCurrency(_grandTotal)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
