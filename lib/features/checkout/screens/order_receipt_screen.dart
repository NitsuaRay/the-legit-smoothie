import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/receiptScreen/receipt_bottom_action.dart';
import '../widgets/receiptScreen/receipt_fulfillment_card.dart';
import '../widgets/receiptScreen/receipt_header.dart';
import '../widgets/receiptScreen/receipt_items_card.dart';
import '../widgets/receiptScreen/receipt_notes_card.dart';
import '../widgets/receiptScreen/receipt_payment_card.dart';
import '../widgets/receiptScreen/receipt_section_header.dart';
import '../widgets/receiptScreen/receipt_success_hero.dart';
import '../widgets/receiptScreen/receipt_tracking_notice.dart';

class OrderReceiptScreen extends StatelessWidget {
  final String orderId;
  final String orderType;
  final String contactNumber;
  final String? deliveryAddress;
  final String? notes;

  final double originalSubtotal;
  final double discountAmount;
  final String? promotionTitle;

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

    required this.originalSubtotal,
    required this.discountAmount,
    this.promotionTitle,

    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,

    required this.items,
    required this.orderDate,
  });

  bool get _isDelivery => orderType.toLowerCase() == 'delivery';

  int get _totalItemCount {
    return items.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] as num?)?.toInt() ?? 0),
    );
  }

  String get _shortOrderId {
    if (orderId.isEmpty) return 'ORDER';

    final int length = orderId.length > 8 ? 8 : orderId.length;

    return orderId.substring(0, length).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const ReceiptHeader(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReceiptSuccessHero(
                        orderNumber: _shortOrderId,
                        total: grandTotal,
                        orderDate: orderDate,
                        isDelivery: _isDelivery,
                      ),

                      const SizedBox(height: 28),

                      ReceiptSectionHeader(
                        eyebrow: 'FULFILLMENT',
                        title: _isDelivery
                            ? 'Delivery details'
                            : 'Pickup details',
                        subtitle: _isDelivery
                            ? 'Where and how we’ll reach you.'
                            : 'Information for collecting your order.',
                        icon: _isDelivery
                            ? Icons.local_shipping_outlined
                            : Icons.storefront_outlined,
                      ),

                      const SizedBox(height: 13),

                      ReceiptFulfillmentCard(
                        isDelivery: _isDelivery,
                        contactNumber: contactNumber,
                        deliveryAddress: deliveryAddress,
                      ),

                      if (notes != null && notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),

                        ReceiptNotesCard(notes: notes!.trim()),
                      ],

                      const SizedBox(height: 28),

                      ReceiptSectionHeader(
                        eyebrow: 'YOUR ORDER',
                        title: 'Items ordered',
                        subtitle:
                            '$_totalItemCount ${_totalItemCount == 1 ? 'item' : 'items'} included in this order.',
                        icon: Icons.shopping_bag_outlined,
                      ),

                      const SizedBox(height: 13),

                      ReceiptItemsCard(
                        items: items,
                        originalSubtotal: originalSubtotal,
                        discountAmount: discountAmount,
                        promotionTitle: promotionTitle,
                      ),
                      const SizedBox(height: 28),

                      const ReceiptSectionHeader(
                        eyebrow: 'PAYMENT',
                        title: 'Order summary',
                        subtitle: 'A complete breakdown of your order total.',
                        icon: Icons.payments_outlined,
                      ),

                      const SizedBox(height: 13),

                      ReceiptPaymentCard(
                        itemCount: _totalItemCount,
                        isDelivery: _isDelivery,

                        originalSubtotal: originalSubtotal,
                        discountAmount: discountAmount,
                        promotionTitle: promotionTitle,

                        subtotal: subtotal,
                        deliveryFee: deliveryFee,
                        grandTotal: grandTotal,
                      ),
                      const SizedBox(height: 16),

                      ReceiptTrackingNotice(isDelivery: _isDelivery),
                    ],
                  ),
                ),
              ),

              const ReceiptBottomAction(),
            ],
          ),
        ),
      ),
    );
  }
}
