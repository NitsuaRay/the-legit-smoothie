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
  late final Future<List<Map<String, dynamic>>> _itemsFuture;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    // Subscribe to real-time changes on the specific order record
    _orderStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.orderId);

    // Fetch the items associated with this order
    _itemsFuture = supabase
        .from('order_items')
        .select()
        .eq('order_id', widget.orderId);
  }

  int _getStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'preparing':
        return 2;
      case 'out_for_delivery':
      case 'ready_for_pickup':
        return 3;
      case 'completed':
        return 4;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final TextEditingController reasonController = TextEditingController();
    String? selectedPresetReason;

    final presetReasons = [
      'Changed my mind',
      'Ordered by mistake',
      'Delivery time takes too long',
      'Need to modify items in order',
      'Other',
    ];

    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isOtherSelected = selectedPresetReason == 'Other';
            final customReason = reasonController.text.trim();

            final canConfirm =
                selectedPresetReason != null &&
                (!isOtherSelected || customReason.isNotEmpty);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 32,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Center(
                            child: Text(
                              'Cancel Order?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Center(
                            child: Text(
                              'Tell us why you want to cancel this order.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          RadioGroup<String>(
                            groupValue: selectedPresetReason,
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPresetReason = value;
                              });
                            },
                            child: Column(
                              children: presetReasons.map((reason) {
                                final isSelected =
                                    selectedPresetReason == reason;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      setDialogState(() {
                                        selectedPresetReason = reason;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.08,
                                              )
                                            : AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border.withValues(
                                                  alpha: 0.7,
                                                ),

                                          width: isSelected ? 1.4 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: reason,
                                            activeColor: AppColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              reason,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                height: 1.25,
                                                color: AppColors.textPrimary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: isOtherSelected
                                ? Padding(
                                    key: const ValueKey('other_reason_field'),
                                    padding: const EdgeInsets.only(top: 4),
                                    child: TextField(
                                      controller: reasonController,
                                      maxLines: 3,
                                      minLines: 2,
                                      onChanged: (_) => setDialogState(() {}),
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Type your reason here...',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.border.withValues(
                                          alpha: 0.12,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 14,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.border.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.border.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Once cancelled, this action cannot be undone.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: AppColors.border.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text(
                                    'Keep Order',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    backgroundColor: AppColors.error,
                                    disabledBackgroundColor: AppColors.error
                                        .withValues(alpha: 0.35),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: canConfirm
                                      ? () {
                                          Navigator.pop(dialogContext, true);
                                        }
                                      : null,
                                  child: const Text(
                                    'Cancel Order',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (shouldCancel == true) {
      final finalReason = selectedPresetReason == 'Other'
          ? reasonController.text.trim()
          : selectedPresetReason;

      _cancelOrder(finalReason ?? 'No reason provided');
    }

    reasonController.dispose();
  }

  Future<void> _cancelOrder(String reason) async {
    setState(() => _isCancelling = true);

    try {
      await supabase
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order has been successfully cancelled.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Tracking')),
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
          final double totalPrice = (orderData['total_price'] as num)
              .toDouble();
          final String? address = orderData['delivery_address'];
          final String? cancelReason = orderData['cancel_reason'];
          final String? notes = orderData['notes'];
          final dynamic createdAt = orderData['created_at'];

          final int currentStep = _getStepIndex(status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Bar: Order ID & Status Badge
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    size: 18,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ORDER ID',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '#${widget.orderId.substring(0, 8).toUpperCase()}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Status Pill Indicator
                            Builder(
                              builder: (context) {
                                final isCancelled = status == 'cancelled';
                                final badgeColor = isCancelled
                                    ? AppColors.error
                                    : AppColors.secondaryDark;
                                final badgeBg = isCancelled
                                    ? AppColors.error.withValues(alpha: 0.1)
                                    : AppColors.primaryAccent.withValues(
                                        alpha: 0.12,
                                      );

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        status.toUpperCase().replaceAll(
                                          '_',
                                          ' ',
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: badgeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border,
                      ),

                      // 2. Main Details Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total Price Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  AppHelpers.formatCurrency(totalPrice),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Order Metadata Chips / Info Rows
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        createdAt != null
                                            ? (createdAt is DateTime
                                                  ? AppHelpers.formatDate(
                                                      createdAt,
                                                    )
                                                  : AppHelpers.formatDate(
                                                      DateTime.parse(
                                                        createdAt.toString(),
                                                      ),
                                                    ))
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          orderType.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Optional Delivery Address Section
                                  if (orderType == 'delivery' &&
                                      address != null) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: AppColors.border,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            address,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.3,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  // Optional Order Notes Section
                                  if (notes != null &&
                                      notes.toString().trim().isNotEmpty) ...[
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Divider(
                                        height: 1,
                                        color: AppColors.border,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.note_alt_outlined,
                                          size: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            notes,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              height: 1.3,
                                              fontWeight: FontWeight.w400,
                                              fontStyle: FontStyle.italic,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        AppConstants.defaultBorderRadius,
                      ),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
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
                        if (cancelReason != null &&
                            cancelReason.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Reason: $cancelReason',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.error.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
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

                const SizedBox(height: 24),

                // Order Items Summary Section
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOrderItemsList(),

                // Show Cancel Button only when Order Status is 'pending'
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
                      onPressed: _isCancelling
                          ? null
                          : () => _showCancelDialog(context),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text(
            'No item details found.',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }

        final items = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.border, height: 24),
            itemBuilder: (context, index) {
              final item = items[index];
              final String name = item['product_name'] ?? 'Item';
              final int quantity = item['quantity'] ?? 1;
              final double totalItemPrice = ((item['total_price'] ?? 0) as num)
                  .toDouble();

              final dynamic rawOptions =
                  item['selected_options'] ??
                  item['options'] ??
                  item['customizations'];
              final Map<String, List<String>> groupedOptions = {};

              if (rawOptions is List) {
                for (final opt in rawOptions) {
                  if (opt is Map) {
                    final String group = opt['group']?.toString() ?? 'Options';
                    final String name = opt['name']?.toString() ?? '';

                    if (name.isNotEmpty) {
                      groupedOptions.putIfAbsent(group, () => []).add(name);
                    }
                  }
                }
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${quantity}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (groupedOptions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ...groupedOptions.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                '• ${entry.key}: ${entry.value.join(', ')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppHelpers.formatCurrency(totalItemPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusStepper(int currentStep, String orderType) {
    final steps = [
      {
        'title': 'Pending',
        'desc': 'Order submitted. Waiting for seller confirmation.',
      },
      {'title': 'Order Accepted', 'desc': 'Seller has accepted your order.'},
      {'title': 'Preparing', 'desc': 'We are crafting your drinks & food.'},
      {
        'title': orderType == 'delivery'
            ? 'Out for Delivery'
            : 'Ready for Pickup',
        'desc': orderType == 'delivery'
            ? 'Rider is on the way to you.'
            : 'Your order is ready at the counter.',
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
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
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
