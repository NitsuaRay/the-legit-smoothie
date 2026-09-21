import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'checkout_card.dart';
import 'checkout_divider.dart';
import 'checkout_input_decoration.dart';

class CheckoutContactCard extends StatelessWidget {
  final TextEditingController contactController;
  final TextEditingController addressController;
  final TextEditingController notesController;

  final String orderType;
  final bool isLoading;
  final VoidCallback onEditProfile;

  const CheckoutContactCard({
    super.key,
    required this.contactController,
    required this.addressController,
    required this.notesController,
    required this.orderType,
    required this.isLoading,
    required this.onEditProfile,
  });

  bool get _hasContact => contactController.text.trim().isNotEmpty;

  bool get _hasAddress => addressController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Information',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Managed from your profile',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditProfile,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.30),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const CheckoutDivider(),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            )
          else ...[
            const Text(
              'CONTACT NUMBER',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 7),

            TextFormField(
              controller: contactController,
              readOnly: true,
              showCursor: false,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: buildCheckoutInputDecoration(
                label: '',
                hint: 'No contact number saved',
                icon: Icons.phone_outlined,
                suffixIcon: _hasContact
                    ? const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.success,
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please add a contact number in your profile';
                }

                return null;
              },
            ),

            // =============================================================
            // DELIVERY ADDRESS
            // Only shown when Delivery is selected
            // =============================================================
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: orderType == 'delivery'
                  ? Column(
                      key: const ValueKey('delivery-address'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),

                        const Text(
                          'DELIVERY ADDRESS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller: addressController,
                          readOnly: true,
                          showCursor: false,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: buildCheckoutInputDecoration(
                            label: '',
                            hint: 'No delivery address saved',
                            icon: Icons.location_on_outlined,
                            suffixIcon: _hasAddress
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.success,
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (orderType == 'delivery' &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please add a delivery address in your profile';
                            }

                            return null;
                          },
                        ),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey('pickup-address')),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'Order Instructions',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'OPTIONAL',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                      color: AppColors.textSecondary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            TextFormField(
              controller: notesController,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: buildCheckoutInputDecoration(
                label: 'Notes / Instructions',
                hint: 'e.g. Less sugar, call upon arrival',
                icon: Icons.note_alt_outlined,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
