import 'package:flutter/material.dart';
import 'profile_info_tile.dart';
import 'profile_section_container.dart';
import '../../../core/constants/app_colors.dart';

class DeliveryInformationSection extends StatelessWidget {
  final String phone;
  final String address;
  final VoidCallback onEditPhone;
  final VoidCallback onEditAddress;

  const DeliveryInformationSection({
    super.key,
    required this.phone,
    required this.address,
    required this.onEditPhone,
    required this.onEditAddress,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionContainer(
      title: 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      children: [
        // Subtitle
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: 12,
            ),
            child: Text(
              'Used for your orders',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.8,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Phone
        ProfileInfoTile(
          label: 'Default Phone Number',
          value: phone,
          icon: Icons.phone_outlined,
          onEdit: onEditPhone,
        ),

        const Divider(
          color: AppColors.border,
          height: 24,
        ),

        // Address
        ProfileInfoTile(
          label: 'Default Delivery Address',
          value: address,
          icon: Icons.location_on_outlined,
          onEdit: onEditAddress,
        ),
      ],
    );
  }
}