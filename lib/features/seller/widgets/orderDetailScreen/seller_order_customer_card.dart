import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';

class SellerOrderCustomerCard extends StatelessWidget {
  final String customerName;
  final String phoneNumber;
  final String address;
  final String notes;
  final String orderType;
  final bool isDelivery;

  const SellerOrderCustomerCard({
    super.key,
    required this.customerName,
    required this.phoneNumber,
    required this.address,
    required this.notes,
    required this.orderType,
    required this.isDelivery,
  });

  // ============================================================
  // CALL CUSTOMER
  // ============================================================

  Future<void> _callCustomer(BuildContext context) async {
    final String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanedNumber.isEmpty) return;

    final Uri uri = Uri(scheme: 'tel', path: cleanedNumber);

    final bool launched = await launchUrl(uri);

    if (!launched && context.mounted) {
      _showMessage(context, 'Unable to open the phone app.');
    }
  }

  // ============================================================
  // OPEN DELIVERY ADDRESS
  // ============================================================

  Future<void> _openDirections(BuildContext context) async {
    final String cleanAddress = address.trim();

    if (cleanAddress.isEmpty) return;

    final Uri uri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': cleanAddress,
      'travelmode': 'driving',
    });

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      _showMessage(context, 'Unable to open directions.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final String displayPhone = _formatPhoneNumber(phoneNumber);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // CUSTOMER
          // =====================================================
          _CustomerIdentity(customerName: customerName),

          const SizedBox(height: 16),

          _OrderTypePanel(orderType: orderType, isDelivery: isDelivery),

          // =====================================================
          // PHONE
          // =====================================================
          if (phoneNumber.trim().isNotEmpty) ...[
            const SizedBox(height: 16),

            _ContactPanel(
              phoneNumber: displayPhone,
              onCall: () => _callCustomer(context),
            ),
          ],

          // =====================================================
          // DELIVERY ADDRESS
          // =====================================================
          if (isDelivery && address.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            _DeliveryAddressPanel(
              address: address.trim(),
              onOpenMap: () => _openDirections(context),
            ),
          ],

          // =====================================================
          // ORDER NOTES
          // =====================================================
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            _OrderNotes(notes: notes.trim()),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT PHONE NUMBER
  // ============================================================

  String _formatPhoneNumber(String value) {
    final String trimmed = value.trim();

    if (trimmed.isEmpty) return '';

    final String digits = trimmed.replaceAll(RegExp(r'\D'), '');

    // Philippine mobile format:
    // 09171234567 -> 0917 123 4567
    if (digits.length == 11 && digits.startsWith('09')) {
      return '${digits.substring(0, 4)} '
          '${digits.substring(4, 7)} '
          '${digits.substring(7)}';
    }

    // +639171234567 -> +63 917 123 4567
    if (digits.length == 12 && digits.startsWith('63')) {
      return '+63 '
          '${digits.substring(2, 5)} '
          '${digits.substring(5, 8)} '
          '${digits.substring(8)}';
    }

    return trimmed;
  }
}

// ===================================================================
// CUSTOMER IDENTITY
// ===================================================================

class _CustomerIdentity extends StatelessWidget {
  final String customerName;

  const _CustomerIdentity({required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // =========================================================
        // AVATAR
        // =========================================================
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 21,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 13),

        // =========================================================
        // NAME
        // =========================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CUSTOMER',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 7),

              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
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
// CONTACT PANEL
// ===================================================================

class _ContactPanel extends StatelessWidget {
  final String phoneNumber;
  final VoidCallback onCall;

  const _ContactPanel({required this.phoneNumber, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          // =======================================================
          // PHONE ICON
          // =======================================================
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: const Icon(
              Icons.phone_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          // =======================================================
          // NUMBER
          // =======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTACT NUMBER',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.85,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // =======================================================
          // CALL BUTTON
          // =======================================================
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCall,
              borderRadius: BorderRadius.circular(11),
              child: Ink(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call_outlined, size: 15, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// DELIVERY ADDRESS
// ===================================================================

class _DeliveryAddressPanel extends StatelessWidget {
  final String address;
  final VoidCallback onOpenMap;

  const _DeliveryAddressPanel({required this.address, required this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // ADDRESS HEADER
          // =======================================================
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.30),
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 19,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY ADDRESS',
                      style: TextStyle(
                        fontSize: 7.5,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.85,
                        color: AppColors.textSecondary.withValues(alpha: 0.55),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Customer destination',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          // =======================================================
          // ADDRESS
          // =======================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.24),
              ),
            ),
            child: SelectableText(
              address,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.05,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 11),

          // =======================================================
          // MAP BUTTON
          // =======================================================
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: onOpenMap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_outlined, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'Get Directions',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.open_in_new_rounded, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// ORDER NOTES
// ===================================================================

class _OrderNotes extends StatelessWidget {
  final String notes;

  const _OrderNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: const Icon(
              Icons.sticky_note_2_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER NOTES',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.85,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
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
}
// ===================================================================
// ORDER TYPE
// ===================================================================

class _OrderTypePanel extends StatelessWidget {
  final String orderType;
  final bool isDelivery;

  const _OrderTypePanel({required this.orderType, required this.isDelivery});

  String get _formattedType {
    switch (orderType.toLowerCase()) {
      case 'delivery':
        return 'Delivery';

      case 'pickup':
        return 'Pickup';

      default:
        if (orderType.trim().isEmpty) {
          return 'Order';
        }

        return orderType
            .replaceAll('_', ' ')
            .split(' ')
            .where((word) => word.isNotEmpty)
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: Icon(
              isDelivery
                  ? Icons.delivery_dining_outlined
                  : Icons.storefront_outlined,
              size: 19,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER TYPE',
                  style: TextStyle(
                    fontSize: 7.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.85,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _formattedType,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: Text(
              isDelivery ? 'DELIVERY' : 'PICKUP',
              style: const TextStyle(
                fontSize: 8,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
