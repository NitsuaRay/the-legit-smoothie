import 'package:flutter/material.dart';
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

  double get _deliveryFee => _orderType == 'delivery' ? _deliveryFeeAmount : 0.0;
  double get _grandTotal => _cartService.subtotal + _deliveryFee;

  @override
  void dispose() {
    _addressController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_orderType == 'delivery' && !_formKey.currentState!.validate()) {
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to place an order.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Insert Master Order record into Supabase
      final orderResponse = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'order_type': _orderType,
            'delivery_address':
                _orderType == 'delivery' ? _addressController.text.trim() : null,
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

      // 2. Prepare Order Items with selected options JSON
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

      // 3. Insert Order Items into Supabase
      await supabase.from('order_items').insert(orderItemsData);

      // 4. Clear cart after successful order creation
      _cartService.clearCart();

      if (!mounted) return;

      // Navigate to order confirmation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Order Placed! 🎉'),
          content: Text(
            'Your order #$orderId has been successfully submitted and is pending confirmation.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Back to Home
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Type Selection
              const Text(
                'Order Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('🛵 Delivery'),
                        ),
                      ),
                      selected: _orderType == 'delivery',
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: _orderType == 'delivery'
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _orderType = 'delivery');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('🛍️ Store Pickup'),
                        ),
                      ),
                      selected: _orderType == 'pickup',
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: TextStyle(
                        color: _orderType == 'pickup'
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _orderType = 'pickup');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact & Address Details Form
              const Text(
                'Contact & Delivery Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Contact Phone Number
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary),
                  hintText: 'e.g., 09123456789',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number for order updates';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Delivery Address (Only required for Delivery)
              if (_orderType == 'delivery') ...[
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    prefixIcon:
                        Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                    hintText: 'Street, Barangay, City / Landmark',
                  ),
                  validator: (value) {
                    if (_orderType == 'delivery' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please provide complete delivery address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Special Instructions
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Special Notes / Rider Instructions',
                  prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textSecondary),
                  hintText: 'e.g., Extra ice, call upon arrival',
                ),
              ),
              const SizedBox(height: 24),

              // Payment Summary Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text(AppHelpers.formatCurrency(_cartService.subtotal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee',
                            style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          _orderType == 'delivery'
                              ? AppHelpers.formatCurrency(_deliveryFee)
                              : 'FREE (Pickup)',
                          style: TextStyle(
                            color: _orderType == 'pickup'
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppHelpers.formatCurrency(_grandTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Confirm Order Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Place Order (${AppHelpers.formatCurrency(_grandTotal)})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}