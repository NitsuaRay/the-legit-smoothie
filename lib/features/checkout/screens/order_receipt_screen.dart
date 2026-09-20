import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // =============================================================
  // HELPERS
  // =============================================================

  bool get _isDelivery {
    return orderType.toLowerCase() == 'delivery';
  }

  int get _totalItemCount {
    return items.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['quantity'] as num?)?.toInt() ?? 0),
    );
  }

  String get _shortOrderId {
    if (orderId.isEmpty) {
      return 'ORDER';
    }

    final length = orderId.length > 8 ? 8 : orderId.length;

    return orderId.substring(0, length).toUpperCase();
  }

  String get _formattedDate {
    return DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(orderDate.toLocal());
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,

        // =========================================================
        // APP BAR
        // =========================================================

        appBar: MainAppBar(
          showLogo: false,
          showBackButton: false,
          showStoreStatus: false,
          titleWidget: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Confirmed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.45,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Your order has been received',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // =========================================================
        // BODY
        // =========================================================

        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    20,
                    18,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // SUCCESS HERO
                      // =============================================

                      _buildSuccessHero(),

                      const SizedBox(height: 28),

                      // =============================================
                      // FULFILLMENT
                      // =============================================

                      _SectionHeader(
                        eyebrow: 'FULFILLMENT',
                        title: _isDelivery
                            ? 'Delivery Details'
                            : 'Pickup Details',
                        subtitle: _isDelivery
                            ? 'Where and how we’ll reach you.'
                            : 'Information for collecting your order.',
                        icon: _isDelivery
                            ? Icons.local_shipping_outlined
                            : Icons.storefront_outlined,
                      ),

                      const SizedBox(height: 13),

                      _buildFulfillmentCard(),

                      // =============================================
                      // NOTES
                      // =============================================

                      if (notes != null &&
                          notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),

                        _buildNotesCard(),
                      ],

                      const SizedBox(height: 28),

                      // =============================================
                      // ITEMS
                      // =============================================

                      _SectionHeader(
                        eyebrow: 'YOUR ORDER',
                        title: 'Items Ordered',
                        subtitle:
                            '$_totalItemCount ${_totalItemCount == 1 ? 'item' : 'items'} included in this order.',
                        icon: Icons.shopping_bag_outlined,
                      ),

                      const SizedBox(height: 13),

                      _buildItemsCard(),

                      const SizedBox(height: 28),

                      // =============================================
                      // PAYMENT SUMMARY
                      // =============================================

                      const _SectionHeader(
                        eyebrow: 'PAYMENT',
                        title: 'Order Summary',
                        subtitle:
                            'A complete breakdown of your order total.',
                        icon: Icons.payments_outlined,
                      ),

                      const SizedBox(height: 13),

                      _buildPaymentCard(),

                      const SizedBox(height: 18),

                      // =============================================
                      // STATUS INFO
                      // =============================================

                      _buildTrackingNotice(),
                    ],
                  ),
                ),
              ),

              // ===================================================
              // FIXED BOTTOM CTA
              // ===================================================

              _buildBottomAction(context),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // SUCCESS HERO
  // =============================================================

  Widget _buildSuccessHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.10,
            ),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // =======================================================
          // SUCCESS ICON
          // =======================================================

          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 23,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // =======================================================
          // TITLE
          // =======================================================

          const Text(
            'Order placed!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.75,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            _isDelivery
                ? 'We’ve received your order and will start preparing it shortly.'
                : 'We’ve received your order and will let you know when it’s ready for pickup.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(
                alpha: 0.67,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =======================================================
          // ORDER ID + TOTAL
          // =======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.075,
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER NUMBER',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: Colors.white.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '#$_shortOrderId',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(
                    alpha: 0.10,
                  ),
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: Colors.white.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      AppHelpers.formatCurrency(
                        grandTotal,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          // =======================================================
          // DATE
          // =======================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: Colors.white.withValues(
                  alpha: 0.50,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                _formattedDate,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(
                    alpha: 0.58,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // FULFILLMENT CARD
  // =============================================================

  Widget _buildFulfillmentCard() {
    return _ReceiptCard(
      child: Column(
        children: [
          _DetailRow(
            icon: _isDelivery
                ? Icons.delivery_dining_outlined
                : Icons.storefront_outlined,
            label: 'Order Type',
            value: _isDelivery
                ? 'Delivery'
                : 'Store Pickup',
          ),

          const _ReceiptDivider(),

          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact Number',
            value: contactNumber,
          ),

          if (_isDelivery &&
              deliveryAddress != null &&
              deliveryAddress!.trim().isNotEmpty) ...[
            const _ReceiptDivider(),

            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Delivery Address',
              value: deliveryAddress!,
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // NOTES CARD
  // =============================================================

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.sticky_note_2_outlined,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER INSTRUCTIONS',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.50,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  notes!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // ITEMS CARD
  // =============================================================

  Widget _buildItemsCard() {
    return _ReceiptCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Container(
              height: 1,
              color: AppColors.border.withValues(
                alpha: 0.22,
              ),
            ),
          );
        },
        itemBuilder: (context, index) {
          final item = items[index];

          return _OrderItemRow(
            item: item,
          );
        },
      ),
    );
  }

  // =============================================================
  // PAYMENT CARD
  // =============================================================

  Widget _buildPaymentCard() {
    return _ReceiptCard(
      child: Column(
        children: [
          _PaymentRow(
            label: 'Subtotal',
            subtitle:
                '$_totalItemCount ${_totalItemCount == 1 ? 'item' : 'items'}',
            value: AppHelpers.formatCurrency(
              subtotal,
            ),
          ),

          const _ReceiptDivider(),

          _PaymentRow(
            label: _isDelivery
                ? 'Delivery Fee'
                : 'Store Pickup',
            subtitle: _isDelivery
                ? 'Standard local delivery'
                : 'No delivery charge',
            value: _isDelivery
                ? AppHelpers.formatCurrency(
                    deliveryFee,
                  )
                : 'FREE',
            valueColor: !_isDelivery
                ? AppColors.success
                : null,
          ),

          const _ReceiptDivider(
            verticalPadding: 17,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Amount for this order',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              Text(
                AppHelpers.formatCurrency(
                  grandTotal,
                ),
                style: const TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // TRACKING NOTICE
  // =============================================================

  Widget _buildTrackingNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.28,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 17,
              color: AppColors.success,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What happens next?',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _isDelivery
                      ? 'Track your order to see when it is accepted, prepared, and sent out for delivery.'
                      : 'Track your order to see when it is accepted, prepared, and ready for pickup.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BOTTOM ACTION
  // =============================================================

  Widget _buildBottomAction(
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        13,
        18,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(
              alpha: 0.28,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 26,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) =>
                    const MainNavigationScreen(
                  initialIndex: 3,
                ),
              ),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.near_me_outlined,
                size: 17,
                color: Colors.white,
              ),

              SizedBox(width: 9),

              Text(
                'Track Your Order',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 9),

              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// SECTION HEADER
// ===================================================================

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.30,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.50,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// RECEIPT CARD
// ===================================================================

class _ReceiptCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _ReceiptCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.045,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ===================================================================
// DETAIL ROW
// ===================================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.48,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// ORDER ITEM
// ===================================================================

class _OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;

  const _OrderItemRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final int quantity =
        (item['quantity'] as num?)?.toInt() ?? 0;

    final double unitPrice =
        (item['unit_price'] as num?)?.toDouble() ?? 0;

    final double totalPrice =
        (item['total_price'] as num?)?.toDouble() ?? 0;

    final String productName =
        item['product_name']?.toString() ?? 'Product';

    final groupedOptions = _parseOptions(
      item['selected_options'],
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // QUANTITY
          // =======================================================

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$quantity×',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // =======================================================
          // PRODUCT
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (groupedOptions.isNotEmpty) ...[
                  const SizedBox(height: 7),

                  ...groupedOptions.entries.map(
                    (entry) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 3,
                        ),
                        child: Text(
                          '${entry.key}: '
                          '${entry.value.join(', ')}',
                          style: TextStyle(
                            fontSize: 9.5,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                if (unitPrice > 0) ...[
                  const SizedBox(height: 6),

                  Text(
                    '$quantity × '
                    '${AppHelpers.formatCurrency(unitPrice)}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(
                        alpha: 0.52,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // =======================================================
          // TOTAL
          // =======================================================

          Text(
            AppHelpers.formatCurrency(
              totalPrice,
            ),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _parseOptions(
    dynamic rawOptions,
  ) {
    final Map<String, List<String>> grouped = {};

    if (rawOptions is! List) {
      return grouped;
    }

    for (final option in rawOptions) {
      if (option is! Map) {
        continue;
      }

      final String group =
          option['group']?.toString().trim() ?? '';

      final String name =
          option['name']?.toString().trim() ?? '';

      if (name.isEmpty) {
        continue;
      }

      final String safeGroup =
          group.isEmpty ? 'Option' : group;

      grouped.putIfAbsent(
        safeGroup,
        () => [],
      );

      grouped[safeGroup]!.add(name);
    }

    return grouped;
  }
}

// ===================================================================
// PAYMENT ROW
// ===================================================================

class _PaymentRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final Color? valueColor;

  const _PaymentRow({
    required this.label,
    required this.subtitle,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.58,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// DIVIDER
// ===================================================================

class _ReceiptDivider extends StatelessWidget {
  final double verticalPadding;

  const _ReceiptDivider({
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
      ),
      child: Container(
        height: 1,
        color: AppColors.border.withValues(
          alpha: 0.22,
        ),
      ),
    );
  }
}