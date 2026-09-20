import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';

// Seller Order Widgets
import '../widgets/seller_order_bottom_actions.dart';
import '../widgets/seller_order_cancellation_card.dart';
import '../widgets/seller_order_customer_card.dart';
import '../widgets/seller_order_hero.dart';
import '../widgets/seller_order_items_card.dart';
import '../widgets/seller_order_payment_card.dart';
import '../widgets/seller_order_section_header.dart';
import '../widgets/seller_order_timeline.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState
    extends State<SellerOrderDetailScreen> {
  // ============================================================
  // STATE
  // ============================================================

  Map<String, dynamic>? _order;

  bool _isLoading = true;
  bool _isUpdatingStatus = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  // ============================================================
  // LOAD ORDER
  // ============================================================

  Future<void> _loadOrder() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await supabase
          .from('orders')
          .select('''
            id,
            user_id,
            status,
            order_type,
            total_amount,
            delivery_address,
            contact_number,
            notes,
            created_at,
            updated_at,
            delivery_fee,
            subtotal,
            total_price,
            cancel_reason,

            customer:profiles!orders_user_id_fkey (
              id,
              full_name,
              phone_number,
              avatar_url
            ),

            order_items (
              id,
              product_id,
              product_name,
              quantity,
              unit_price,
              selected_options,
              total_price
            ),

            order_status_history (
              id,
              status,
              changed_by,
              note,
              created_at
            )
          ''')
          .eq(
            'id',
            widget.orderId,
          )
          .single();

      if (!mounted) return;

      setState(() {
        _order = Map<String, dynamic>.from(
          response,
        );

        _isLoading = false;
      });
    } catch (error) {
      debugPrint(
        'Seller order detail error: $error',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load this order right now.';
      });
    }
  }

  // ============================================================
  // ORDER DATA
  // ============================================================

  String get _status {
    return _order?['status']
            ?.toString()
            .toLowerCase() ??
        'pending';
  }

  String get _orderType {
    return _order?['order_type']
            ?.toString()
            .toLowerCase() ??
        '';
  }

  bool get _isDelivery {
    return _orderType == 'delivery';
  }

  // ============================================================
  // CUSTOMER
  // ============================================================

  String get _customerName {
    final customer = _order?['customer'];

    if (customer is Map) {
      final String name =
          customer['full_name']
                  ?.toString()
                  .trim() ??
              '';

      if (name.isNotEmpty) {
        return name;
      }
    }

    return 'Customer';
  }

  String get _phoneNumber {
    // Prefer the number supplied during checkout.
    final String orderPhone =
        _order?['contact_number']
                ?.toString()
                .trim() ??
            '';

    if (orderPhone.isNotEmpty) {
      return orderPhone;
    }

    // Otherwise use the customer's profile number.
    final customer = _order?['customer'];

    if (customer is Map) {
      return customer['phone_number']
              ?.toString()
              .trim() ??
          '';
    }

    return '';
  }

  // ============================================================
  // ORDER ITEMS
  // ============================================================

  List<Map<String, dynamic>> get _items {
    final data = _order?['order_items'];

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();
  }

  // ============================================================
  // ORDER HISTORY
  // ============================================================

  List<Map<String, dynamic>> get _history {
    final data =
        _order?['order_status_history'];

    if (data is! List) {
      return [];
    }

    final history = data
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();

    history.sort(
      (a, b) {
        final DateTime? aDate =
            DateTime.tryParse(
          a['created_at']?.toString() ?? '',
        );

        final DateTime? bDate =
            DateTime.tryParse(
          b['created_at']?.toString() ?? '',
        );

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return -1;
        }

        if (bDate == null) {
          return 1;
        }

        return aDate.compareTo(bDate);
      },
    );

    return history;
  }

  // ============================================================
  // PRICE CALCULATIONS
  // ============================================================

  double get _subtotal {
    return (_order?['subtotal'] as num?)
            ?.toDouble() ??
        _calculateItemsSubtotal();
  }

  double get _deliveryFee {
    return (_order?['delivery_fee'] as num?)
            ?.toDouble() ??
        0;
  }

  double get _total {
    final double? total =
        (_order?['total_price'] as num?)
            ?.toDouble();

    if (total != null) {
      return total;
    }

    // Compatibility with the older total_amount column.
    final double? legacyTotal =
        (_order?['total_amount'] as num?)
            ?.toDouble();

    if (legacyTotal != null) {
      return legacyTotal;
    }

    return _subtotal + _deliveryFee;
  }

  double _calculateItemsSubtotal() {
    double total = 0;

    for (final item in _items) {
      final double itemTotal =
          (item['total_price'] as num?)
                  ?.toDouble() ??
              0;

      total += itemTotal;
    }

    return total;
  }

  int _totalQuantity() {
    int total = 0;

    for (final item in _items) {
      total +=
          (item['quantity'] as num?)
                  ?.toInt() ??
              0;
    }

    return total;
  }

  // ============================================================
  // ORDER STATUS FLOW
  // ============================================================

  String? get _nextStatus {
    switch (_status) {
      case 'pending':
        return 'accepted';

      case 'accepted':
        return 'preparing';

      case 'preparing':
        return _isDelivery
            ? 'out_for_delivery'
            : 'ready_for_pickup';

      case 'out_for_delivery':
      case 'ready_for_pickup':
        return 'completed';

      default:
        return null;
    }
  }

  String get _primaryActionLabel {
    switch (_status) {
      case 'pending':
        return 'Accept Order';

      case 'accepted':
        return 'Start Preparing';

      case 'preparing':
        return _isDelivery
            ? 'Out for Delivery'
            : 'Ready for Pickup';

      case 'out_for_delivery':
        return 'Mark as Delivered';

      case 'ready_for_pickup':
        return 'Complete Pickup';

      default:
        return 'Update Order';
    }
  }

  IconData get _primaryActionIcon {
    switch (_status) {
      case 'pending':
        return Icons.check_rounded;

      case 'accepted':
        return Icons.restaurant_rounded;

      case 'preparing':
        return _isDelivery
            ? Icons.delivery_dining_rounded
            : Icons.shopping_bag_rounded;

      case 'out_for_delivery':
      case 'ready_for_pickup':
        return Icons.task_alt_rounded;

      default:
        return Icons.arrow_forward_rounded;
    }
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<void> _updateStatus(
    String newStatus,
  ) async {
    if (_isUpdatingStatus) {
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await supabase
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at':
                DateTime.now().toIso8601String(),
          })
          .eq(
            'id',
            widget.orderId,
          );

      // order_status_history is NOT inserted here.
      // The PostgreSQL trigger handles that automatically.

      await _loadOrder();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 19,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    'Order updated to ${_formatStatus(newStatus)}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
          ),
        );
    } catch (error) {
      debugPrint(
        'Update order status error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to update the order status.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                14,
              ),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> _showCancelDialog() async {
    final TextEditingController controller =
        TextEditingController();

    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              22,
            ),
          ),
          titlePadding:
              const EdgeInsets.fromLTRB(
            22,
            22,
            22,
            0,
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(
            22,
            14,
            22,
            8,
          ),
          actionsPadding:
              const EdgeInsets.fromLTRB(
            14,
            6,
            14,
            14,
          ),
          title: const Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                size: 21,
                color: AppColors.error,
              ),
              SizedBox(width: 9),
              Text(
                'Cancel Order?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'This will mark the order as cancelled. You can optionally provide a reason for the customer.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                maxLines: 3,
                textCapitalization:
                    TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Reason for cancellation...',
                  hintStyle: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary
                        .withValues(
                      alpha: 0.65,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.all(14),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.border
                          .withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Keep Order',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel Order',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      controller.dispose();
      return;
    }

    final String reason =
        controller.text.trim();

    controller.dispose();

    if (!mounted) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await supabase
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancel_reason':
                reason.isEmpty ? null : reason,
            'updated_at':
                DateTime.now().toIso8601String(),
          })
          .eq(
            'id',
            widget.orderId,
          );

      // Again, order_status_history is handled
      // automatically by the database trigger.

      await _loadOrder();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 19,
                  color: Colors.white,
                ),
                SizedBox(width: 9),
                Text(
                  'Order cancelled.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            backgroundColor:
                AppColors.textPrimary,
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      debugPrint(
        'Cancel order error: $error',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Unable to cancel order.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,

        leading: Padding(
          padding: const EdgeInsets.only(
            left: 12,
          ),
          child: IconButton(
            tooltip: 'Back',
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        titleSpacing: 8,

        title: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.25,
                color: AppColors.textPrimary,
              ),
            ),

            if (_order != null) ...[
              const SizedBox(height: 1),

              Text(
                _shortOrderId(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary
                      .withValues(
                    alpha: 0.75,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            )
          : _errorMessage != null
              ? _buildError()
              : _buildContent(),

      // ========================================================
      // BOTTOM ORDER ACTION
      // ========================================================
      bottomNavigationBar:
          !_isLoading &&
                  _errorMessage == null &&
                  _order != null
              ? SellerOrderBottomActions(
                  status: _status,
                  primaryActionLabel:
                      _primaryActionLabel,
                  primaryActionIcon:
                      _primaryActionIcon,
                  isUpdating:
                      _isUpdatingStatus,
                  canUpdate:
                      _nextStatus != null,
                  onCancelPressed:
                      _showCancelDialog,
                  onPrimaryPressed:
                      _nextStatus == null
                          ? null
                          : () {
                              _updateStatus(
                                _nextStatus!,
                              );
                            },
                )
              : null,
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    final String address =
        _order?['delivery_address']
                ?.toString()
                .trim() ??
            '';

    final String notes =
        _order?['notes']
                ?.toString()
                .trim() ??
            '';

    final DateTime? createdAt =
        DateTime.tryParse(
      _order?['created_at']?.toString() ?? '',
    )?.toLocal();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrder,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppConstants.defaultPadding,
          8,
          AppConstants.defaultPadding,
          30,
        ),
        children: [
          // ==================================================
          // ORDER SUMMARY
          // ==================================================
          SellerOrderHero(
            orderId:
                _order?['id']?.toString() ??
                widget.orderId,
            status: _status,
            orderType: _orderType,
            createdAt: createdAt,
            totalQuantity:
                _totalQuantity(),
            total: _total,
            isDelivery: _isDelivery,
          ),

          const SizedBox(height: 24),

          // ==================================================
          // CUSTOMER
          // ==================================================
          const SellerOrderSectionHeader(
            title: 'Customer',
            subtitle:
                'Customer and fulfillment details.',
          ),

          const SizedBox(height: 11),

          SellerOrderCustomerCard(
            customerName: _customerName,
            phoneNumber: _phoneNumber,
            orderType:
                _formatOrderType(_orderType),
            address: address,
            notes: notes,
            isDelivery: _isDelivery,
          ),

          const SizedBox(height: 24),

          // ==================================================
          // ORDER ITEMS
          // ==================================================
          SellerOrderSectionHeader(
            title: 'Order Items',
            subtitle:
                '${_items.length} '
                '${_items.length == 1 ? 'item' : 'items'} '
                'in this order.',
          ),

          const SizedBox(height: 11),

          SellerOrderItemsCard(
            items: _items,
          ),

          const SizedBox(height: 24),

          // ==================================================
          // PAYMENT
          // ==================================================
          const SellerOrderSectionHeader(
            title: 'Payment Summary',
            subtitle:
                'Order total breakdown.',
          ),

          const SizedBox(height: 11),

          SellerOrderPaymentCard(
            subtotal: _subtotal,
            deliveryFee: _deliveryFee,
            total: _total,
          ),

          const SizedBox(height: 24),

          // ==================================================
          // ORDER PROGRESS
          // ==================================================
          const SellerOrderSectionHeader(
            title: 'Order Progress',
            subtitle:
                'Status updates for this order.',
          ),

          const SizedBox(height: 11),

          SellerOrderTimeline(
            history: _history,
            currentStatus: _status,
          ),

          // ==================================================
          // CANCELLATION INFO
          // ==================================================
          if (_status == 'cancelled') ...[
            const SizedBox(height: 16),

            SellerOrderCancellationCard(
              reason:
                  _order?['cancel_reason']
                          ?.toString()
                          .trim() ??
                      '',
            ),
          ],

          // Extra breathing room above fixed actions.
          const SizedBox(height: 95),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildError() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrder,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(30),
        children: [
          SizedBox(
            height:
                MediaQuery.sizeOf(context).height *
                    0.18,
          ),

          Center(
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(
                  alpha: 0.07,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 30,
                color: AppColors.error,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Couldn\'t load order',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _errorMessage ??
                'Something went wrong.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: OutlinedButton.icon(
              onPressed: _loadOrder,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 17,
              ),
              label: const Text(
                'Try Again',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.textPrimary,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                side: BorderSide(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.7,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _shortOrderId() {
    final String id =
        _order?['id']?.toString() ??
            widget.orderId;

    final String shortId =
        id.length >= 6
            ? id.substring(0, 6)
            : id;

    return '#${shortId.toUpperCase()}';
  }

  String _formatOrderType(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'delivery':
        return 'Delivery';

      case 'pickup':
        return 'Pickup';

      default:
        if (type.trim().isEmpty) {
          return 'Order';
        }

        return _formatStatus(type);
    }
  }

  String _formatStatus(
    String status,
  ) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
        )
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }
}