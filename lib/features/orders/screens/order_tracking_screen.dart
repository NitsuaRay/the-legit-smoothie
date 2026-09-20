import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/orders/widgets/order_widgets.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../widgets/live_order_status.dart';
import '../widgets/order_summary.dart';
import '../widgets/order_tracking_header.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final Stream<List<Map<String, dynamic>>> _orderStream;

  late final Future<List<Map<String, dynamic>>> _itemsFuture;

  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();

    // Real-time order stream
    _orderStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.orderId);

    // Order items
    _itemsFuture = supabase
        .from('order_items')
        .select()
        .eq('order_id', widget.orderId);
  }

  Future<void> _showCancelDialog() async {
    final String? reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CancelOrderDialog(),
    );

    if (!mounted || reason == null) {
      return;
    }

    await _cancelOrder(reason);
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() {
      _isCancelling = true;
    });

    try {
      await supabase
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.orderId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order has been successfully cancelled.'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      debugPrint('Failed to cancel order: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to cancel the order right now. Please try again.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
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
                Icons.local_shipping_rounded,
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
                      'Order Tracking',
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
                    'Track your order status in real time',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Unable to load order status.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final orderData = snapshot.data!.first;

          final String status = (orderData['status'] ?? 'pending')
              .toString()
              .toLowerCase();

          final String orderType = (orderData['order_type'] ?? 'delivery')
              .toString()
              .toLowerCase();

          final double totalPrice = ((orderData['total_price'] ?? 0) as num)
              .toDouble();

          final String? address = orderData['delivery_address']?.toString();

          final String? cancelReason = orderData['cancel_reason']?.toString();

          final String? notes = orderData['notes']?.toString();

          final DateTime? createdAt = _parseCreatedAt(orderData['created_at']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderTrackingHeader(
                  orderId: widget.orderId,
                  status: status,
                  orderType: orderType,
                  totalPrice: totalPrice,
                  address: address,
                  notes: notes,
                  createdAt: createdAt,
                ),

                const SizedBox(height: 24),

                if (status == 'cancelled') ...[
                  CancelledOrderCard(cancelReason: cancelReason),
                ] else ...[
                  LiveOrderStatus(status: status, orderType: orderType),
                ],

                const SizedBox(height: 24),

                OrderSummary(
                  itemsFuture: _itemsFuture,
                  orderType: orderType,
                  totalPrice: totalPrice,
                ),
                
                if (status == 'pending') ...[
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isCancelling ? null : _showCancelDialog,
                      icon: _isCancelling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.remove_shopping_cart_rounded,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isCancelling ? 'Cancelling...' : 'Cancel Order',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
