import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/utils/helpers.dart';
import 'package:the_legit_smoothie/features/orders/widgets/order_widgets.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final Stream<List<Map<String, dynamic>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;

    if (user != null) {
      _ordersStream = supabase
          .from('orders')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
    } else {
      _ordersStream = const Stream.empty();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade800;
      case 'preparing':
        return AppColors.primary;
      case 'out_for_delivery':
      case 'ready_for_pickup':
        return Colors.blue.shade600;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatusLabel(String status) {
    return status.toUpperCase().replaceAll('_', ' ');
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await CancelOrderDialog.show(context);
    if (confirmed != true) return;

    try {
      await supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order cancelled successfully.'),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateNotes(String orderId, String currentNotes) async {
    UpdateNotesDialog.show(
      context: context,
      currentNotes: currentNotes,
      onSave: (newNotes) async {
        try {
          await supabase
              .from('orders')
              .update({'notes': newNotes})
              .eq('id', orderId);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order notes updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update notes: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: MainAppBar(
          showLogo: false,
          showBackButton: true,
          title: 'My Orders',
        ),
        body: const Center(
          child: Text(
            'Please log in to view your order history.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        showLogo: false,
        showBackButton: false,
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading orders: ${snapshot.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      size: 60,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No orders placed yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your past and active orders will appear here.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = orders[index];
              final String orderId = order['id'];
              final String status = (order['status'] ?? 'pending').toString();
              final String orderType = (order['order_type'] ?? 'delivery')
                  .toString();
              final String notes = (order['notes'] ?? '').toString();
              final double totalPrice =
                  (order['total_price'] as num?)?.toDouble() ?? 0.0;
              final DateTime createdAt = DateTime.parse(
                order['created_at'],
              ).toLocal();

              final statusColor = _getStatusColor(status);
              final isPending = status == 'pending';
              final isPreparing = status == 'preparing';
              final isCancelled = status == 'cancelled';

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(orderId: orderId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Top Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    orderType == 'delivery'
                                        ? Icons.delivery_dining_rounded
                                        : Icons.storefront_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${orderId.substring(0, 8).toUpperCase()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${createdAt.day}/${createdAt.month}/${createdAt.year} • ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _formatStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Optional Notes Snippet Display
                        if (notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    notes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),

                        // Card Action Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Price',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                Text(
                                  AppHelpers.formatCurrency(totalPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            // Dynamic Action Buttons
                            Row(
                              children: [
                                // Edit/Add Notes Button (Available during Pending OR Preparing)
                                if (isPending || isPreparing)
                                  IconButton(
                                    onPressed: () =>
                                        _updateNotes(orderId, notes),
                                    icon: const Icon(Icons.edit_note_rounded),
                                    color: AppColors.primary,
                                    tooltip: 'Update Instructions',
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),

                                // Cancel Button (ONLY shown when status is PENDING)
                                if (isPending) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _cancelOrder(orderId),
                                    icon: const Icon(Icons.cancel_outlined),
                                    color: AppColors.error,
                                    tooltip: 'Cancel Order',
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.error
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],

                                const SizedBox(width: 8),

                                // Track Order Action Button
                                if (!isCancelled)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OrderTrackingScreen(
                                            orderId: orderId,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.near_me_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Track',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
              );
            },
          );
        },
      ),
    );
  }
}
