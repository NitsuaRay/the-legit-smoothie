import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SellerOrderCustomerCard extends StatelessWidget {
  final String customerName;
  final String phoneNumber;
  final String orderType;
  final String address;
  final String notes;
  final bool isDelivery;

  const SellerOrderCustomerCard({
    super.key,
    required this.customerName,
    required this.phoneNumber,
    required this.orderType,
    required this.address,
    required this.notes,
    required this.isDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: customerName,
          ),

          if (phoneNumber.isNotEmpty) ...[
            const _CardDivider(),
            _DetailRow(
              icon: Icons.phone_outlined,
              label: 'Contact Number',
              value: phoneNumber,
            ),
          ],

          const _CardDivider(),

          _DetailRow(
            icon: isDelivery
                ? Icons.delivery_dining_outlined
                : Icons.storefront_outlined,
            label: 'Fulfillment',
            value: orderType,
          ),

          if (isDelivery && address.isNotEmpty) ...[
            const _CardDivider(),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Delivery Address',
              value: address,
              multiline: true,
            ),
          ],

          if (notes.isNotEmpty) ...[
            const _CardDivider(),
            _DetailRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Order Notes',
              value: notes,
              multiline: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: multiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
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

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 25,
      indent: 45,
      color: AppColors.border.withValues(alpha: 0.30),
    );
  }
}