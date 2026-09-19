import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/shared/widgets/main_navigation_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class OrderReceiptScreen extends StatelessWidget {
  final String orderId;
  final String orderType;
  final String contactNumber;
  final String? deliveryAddress;
  final String? notes;
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;
  final List<Map<String, dynamic>> items;
  final DateTime orderDate;

  const OrderReceiptScreen({
    super.key,
    required this.orderId,
    required this.orderType,
    required this.contactNumber,
    this.deliveryAddress,
    this.notes,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.items,
    required this.orderDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        showLogo: false,
        showBackButton: false,
        titleWidget: Text(
          'Order Receipt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Receipt Card Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Order Placed Successfully!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order ID: #${orderId.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${orderDate.day}/${orderDate.month}/${orderDate.year} ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer & Order Info Section
                        const Text(
                          'Delivery Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptInfoRow('Type', orderType.toUpperCase()),
                        _buildReceiptInfoRow('Contact', contactNumber),
                        if (orderType == 'delivery' && deliveryAddress != null)
                          _buildReceiptInfoRow('Address', deliveryAddress!),
                        if (notes != null && notes!.isNotEmpty)
                          _buildReceiptInfoRow('Notes', notes!),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),

                        // Ordered Items Breakdown
                        const Text(
                          'Items Ordered',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            // Safely parse selected_options as a List
                            final rawOptions = item['selected_options'];
                            final List<dynamic> optionsList = rawOptions is List
                                ? rawOptions
                                : [];

                            // Group options by their "group" key (e.g., "Size", "Toppings", "Sugar Level")
                            final Map<String, List<String>> groupedOptions = {};

                            for (var opt in optionsList) {
                              if (opt is Map) {
                                final String group =
                                    opt['group']?.toString() ?? 'Option';
                                final String name =
                                    opt['name']?.toString() ?? '';

                                if (name.isNotEmpty) {
                                  groupedOptions
                                      .putIfAbsent(group, () => [])
                                      .add(name);
                                }
                              }
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Quantity Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item['quantity']}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Product Name & Selected Options
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['product_name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      if (groupedOptions.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        ...groupedOptions.entries.map(
                                          (entry) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 2,
                                            ),
                                            child: Text(
                                              '• ${entry.key}: ${entry.value.join(', ')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary
                                                    .withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Total Price
                                Text(
                                  AppHelpers.formatCurrency(
                                    (item['total_price'] as num).toDouble(),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),

                        // Summary Calculations
                        _buildSummaryRow(
                          'Subtotal',
                          AppHelpers.formatCurrency(subtotal),
                        ),
                        const SizedBox(height: 6),
                        _buildSummaryRow(
                          'Delivery Fee',
                          orderType == 'delivery'
                              ? AppHelpers.formatCurrency(deliveryFee)
                              : 'FREE',
                          isSuccess: orderType == 'pickup',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              AppHelpers.formatCurrency(grandTotal),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Track Your Orders CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          const MainNavigationScreen(initialIndex: 3),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Track Your Orders',
                  style: TextStyle(
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
    );
  }

  Widget _buildReceiptInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isSuccess = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSuccess ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
