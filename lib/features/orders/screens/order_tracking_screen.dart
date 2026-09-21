import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

import '../widgets/orderTracking/cancel_order_dialog.dart';
import '../widgets/orderTracking/live_order_status.dart';
import '../widgets/orderTracking/order_cancel_button.dart';
import '../widgets/orderTracking/order_tracking_app_header.dart';
import '../widgets/orderTracking/order_tracking_cancelled_card.dart';
import '../widgets/orderTracking/order_tracking_overview.dart';
import '../widgets/orderTracking/order_tracking_summary.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState
    extends State<OrderTrackingScreen> {
  late final Stream<List<Map<String, dynamic>>> _orderStream;

  late final Future<List<Map<String, dynamic>>> _itemsFuture;

  bool _isCancelling = false;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _orderStream = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', widget.orderId);

    _itemsFuture = supabase
        .from('order_items')
        .select()
        .eq('order_id', widget.orderId);
  }

  // ==============================================================
  // CANCEL DIALOG
  // ==============================================================

  Future<void> _showCancelDialog() async {
    final String? reason =
        await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const CancelOrderDialog(),
    );

    if (!mounted || reason == null) {
      return;
    }

    await _cancelOrder(reason);
  }

  // ==============================================================
  // CANCEL ORDER
  // ==============================================================

  Future<void> _cancelOrder(
    String reason,
  ) async {
    if (_isCancelling) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await supabase
          .from('orders')
          .update({
            'status': 'cancelled',
            'cancel_reason': reason,
            'updated_at': DateTime.now()
                .toUtc()
                .toIso8601String(),
          })
          .eq(
            'id',
            widget.orderId,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            backgroundColor:
                AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Order cancelled successfully.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (e) {
      debugPrint(
        'Failed to cancel order: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Unable to cancel the order right now. Please try again.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
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

  // ==============================================================
  // CREATED DATE
  // ==============================================================

  DateTime? _parseCreatedAt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    try {
      return DateTime.parse(
        value.toString(),
      ).toLocal();
    } catch (_) {
      return null;
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======================================================
            // PAGE HEADER
            // ======================================================

            const OrderTrackingAppHeader(),

            // ======================================================
            // REALTIME ORDER
            // ======================================================

            Expanded(
              child: StreamBuilder<
                  List<Map<String, dynamic>>>(
                stream: _orderStream,
                builder: (
                  context,
                  snapshot,
                ) {
                  // =================================================
                  // LOADING
                  // =================================================

                  if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const _TrackingLoadingState();
                  }

                  // =================================================
                  // ERROR / NOT FOUND
                  // =================================================

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return _TrackingErrorState(
                      onBack: () =>
                          Navigator.of(context)
                              .maybePop(),
                    );
                  }

                  // =================================================
                  // ORDER DATA
                  // =================================================

                  final Map<String, dynamic>
                      orderData =
                      snapshot.data!.first;

                  final String status =
                      (orderData['status'] ??
                              'pending')
                          .toString()
                          .trim()
                          .toLowerCase();

                  final String orderType =
                      (orderData[
                                  'order_type'] ??
                              'delivery')
                          .toString()
                          .trim()
                          .toLowerCase();

                  final double totalPrice =
                      _toDouble(
                    orderData['total_price'],
                  );

                  final String? address =
                      _nullableString(
                    orderData[
                        'delivery_address'],
                  );

                  final String? notes =
                      _nullableString(
                    orderData['notes'],
                  );

                  final String? cancelReason =
                      _nullableString(
                    orderData[
                        'cancel_reason'],
                  );

                  final DateTime? createdAt =
                      _parseCreatedAt(
                    orderData['created_at'],
                  );

                  // =================================================
                  // PAGE
                  // =================================================

                  return SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(
                      parent:
                          AlwaysScrollableScrollPhysics(),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      7,
                      18,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ===========================================
                        // ORDER OVERVIEW
                        // ===========================================

                        OrderTrackingOverview(
                          orderId:
                              widget.orderId,
                          status: status,
                          orderType:
                              orderType,
                          totalPrice:
                              totalPrice,
                          address: address,
                          notes: notes,
                          createdAt:
                              createdAt,
                        ),

                        const SizedBox(
                          height: 23,
                        ),

                        // ===========================================
                        // LIVE TRACKING / CANCELLED
                        // ===========================================

                        if (status ==
                            'cancelled')
                          OrderTrackingCancelledCard(
                            cancelReason:
                                cancelReason,
                          )
                        else
                          LiveOrderStatus(
                            status: status,
                            orderType:
                                orderType,
                            orderId:
                                widget.orderId,
                          ),

                        const SizedBox(
                          height: 23,
                        ),

                        // ===========================================
                        // SUMMARY
                        // ===========================================

                        OrderTrackingSummary(
                          itemsFuture:
                              _itemsFuture,
                          orderType:
                              orderType,
                          totalPrice:
                              totalPrice,
                        ),

                        // ===========================================
                        // CANCELLATION
                        //
                        // Customer cancellation is only available
                        // while the order is pending.
                        // ===========================================

                        if (status ==
                            'pending') ...[
                          const SizedBox(
                            height: 23,
                          ),

                          OrderCancelButton(
                            isLoading:
                                _isCancelling,
                            onPressed:
                                _showCancelDialog,
                          ),
                        ],

                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // HELPERS
  // ==============================================================

  double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  String? _nullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final String text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }
}

// =================================================================
// LOADING STATE
// =================================================================

class _TrackingLoadingState
    extends StatelessWidget {
  const _TrackingLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border
                    .withValues(
                  alpha: 0.28,
                ),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'Loading your order',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w800,
              color:
                  AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Getting the latest status...',
            style: TextStyle(
              fontSize: 9,
              color: AppColors
                  .textSecondary
                  .withValues(
                alpha: 0.68,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// ERROR STATE
// =================================================================

class _TrackingErrorState
    extends StatelessWidget {
  final VoidCallback onBack;

  const _TrackingErrorState({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.28,
                  ),
                ),
              ),
              child: const Icon(
                Icons
                    .receipt_long_outlined,
                size: 25,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Order unavailable',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w900,
                letterSpacing: -0.3,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'We couldn’t load the latest information for this order.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.45,
                color: AppColors
                    .textSecondary
                    .withValues(
                  alpha: 0.72,
                ),
              ),
            ),

            const SizedBox(height: 17),

            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 15,
              ),
              label: const Text(
                'Go back',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    AppColors.textPrimary,
                side: BorderSide(
                  color: AppColors.border
                      .withValues(
                    alpha: 0.50,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    13,
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