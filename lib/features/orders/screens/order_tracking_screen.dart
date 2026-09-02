import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../../main.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late final Stream<List<Map<String, dynamic>>> _orderStream;

  @override
  void initState() {
    super.initState();
    // Subscribe to real-time changes on the specific order record
    _orderStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.orderId);
  }

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'preparing':
        return 1;
      case 'out_for_delivery':
      case 'ready_for_pickup':
        return 2;
      case 'completed':
        return 3;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Tracking'),
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
          final String status = orderData['status'] ?? 'pending';
          final String orderType = orderData['order_type'] ?? 'delivery';
          final double totalPrice =
              (orderData['total_price'] as num).toDouble();
          final String? address = orderData['delivery_address'];

          final int currentStep = _getStepIndex(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID & Status Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${widget.orderId.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'cancelled'
                                  ? AppColors.error.withValues(alpha: 0.15)
                                  : AppColors.primaryAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase().replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: status == 'cancelled'
                                    ? AppColors.error
                                    : AppColors.secondaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${AppHelpers.formatCurrency(totalPrice)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (orderType == 'delivery' && address != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Deliver to: $address',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (status == 'cancelled') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultBorderRadius),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: AppColors.error),
                        SizedBox(width: 12),
                        Text(
                          'This order has been cancelled.',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Progress Tracker Title
                  const Text(
                    'Live Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Real-time Stepper
                  _buildStatusStepper(currentStep, orderType),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusStepper(int currentStep, String orderType) {
    final steps = [
      {'title': 'Order Received', 'desc': 'Store has received your order.'},
      {'title': 'Preparing', 'desc': 'We are crafting your drinks & food.'},
      {
        'title': orderType == 'delivery' ? 'Out for Delivery' : 'Ready for Pickup',
        'desc': orderType == 'delivery'
            ? 'Rider is on the way to you.'
            : 'Your order is ready at the counter.'
      },
      {'title': 'Completed', 'desc': 'Order delivered and enjoyed!'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final isDone = index <= currentStep;
          final isCurrent = index == currentStep;
          final isLast = index == steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Vertical Line Timeline
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isDone ? Icons.check : Icons.circle,
                      size: 16,
                      color: isDone ? Colors.white : AppColors.border,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: isDone && currentStep > index
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Step Title & Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isDone
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        steps[index]['desc']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}