import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class CatalogHomeHeader extends StatelessWidget {
  final bool isStoreOpen;

  const CatalogHomeHeader({super.key, required this.isStoreOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        18,
        AppConstants.defaultPadding,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // BRAND
          // =====================================================
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.30),
                  ),
                ),
                child: Image.asset(
                  'assets/logoSmoothie.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.local_drink_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    );
                  },
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THE LEGIT SMOOTHIE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.1,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Freshly made. Made for you.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              _StoreStatus(isOpen: isStoreOpen),
            ],
          ),

          const SizedBox(height: 26),

          // =====================================================
          // GREETING
          // =====================================================
          Text(
            _greeting.toUpperCase(),
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textSecondary.withValues(alpha: 0.58),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'What are you\ncraving today?',
            style: TextStyle(
              fontSize: 30,
              height: 1.03,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.1,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Smoothies, milk tea, fresh juice and '
            'snacks made for every craving.',
            style: TextStyle(
              fontSize: 10,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final int hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 18) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }
}

class _StoreStatus extends StatelessWidget {
  final bool isOpen;

  const _StoreStatus({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOpen
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog<void>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.38),
            builder: (_) {
              return _StoreStatusDialog(isOpen: isOpen);
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              Text(
                isOpen ? 'OPEN' : 'CLOSED',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(width: 4),

              Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreStatusDialog extends StatelessWidget {
  final bool isOpen;

  const _StoreStatusDialog({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isOpen
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =====================================================
            // TOP
            // =====================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(
                    isOpen
                        ? Icons.storefront_outlined
                        : Icons.store_mall_directory_outlined,
                    size: 22,
                    color: statusColor,
                  ),
                ),

                const Spacer(),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    customBorder: const CircleBorder(),
                    child: Ink(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =====================================================
            // STATUS
            // =====================================================
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 7),

                Text(
                  isOpen ? 'STORE IS OPEN' : 'STORE IS CLOSED',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: statusColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Text(
              isOpen
                  ? 'We’re ready for your order.'
                  : 'You can still order ahead.',
              style: const TextStyle(
                fontSize: 22,
                height: 1.08,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.55,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              isOpen
                  ? 'The store is currently accepting and processing orders. '
                        'Place your order and the seller can begin preparing it.'
                  : 'The store is not currently processing orders. You can '
                        'still place your order now, and it will be processed '
                        'once the store opens again.',
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.74),
              ),
            ),

            const SizedBox(height: 18),

            // =====================================================
            // INFORMATION CARD
            // =====================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      isOpen ? Icons.bolt_rounded : Icons.schedule_rounded,
                      size: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOpen ? 'Processing now' : 'Order ahead',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isOpen
                              ? 'New orders can be seen and processed by the seller.'
                              : 'Your order will wait for the store to reopen before processing.',
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1.4,
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
              ),
            ),

            const SizedBox(height: 18),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.20)),

            const SizedBox(height: 16),

            // =====================================================
            // BUTTON
            // =====================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOpen
                          ? Icons.shopping_bag_outlined
                          : Icons.schedule_send_outlined,
                      size: 17,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      isOpen ? 'Start ordering' : 'Got it',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
