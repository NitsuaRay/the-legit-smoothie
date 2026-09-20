import 'package:flutter/material.dart';
import 'profile_info_tile.dart';
import 'profile_section_container.dart';

class UserInformationSection extends StatelessWidget {
  final String fullName;
  final String email;
  final VoidCallback onEditName;

  const UserInformationSection({
    super.key,
    required this.fullName,
    required this.email,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSectionContainer(
      title: 'User Information',
      icon: Icons.person_outline,
      children: [
        ProfileInfoTile(
          label: 'Full Name',
          value: fullName.isEmpty ? 'Not set' : fullName,
          icon: Icons.badge_outlined,
          onEdit: onEditName,
        ),

        const Divider(
          color: Colors.transparent,
          height: 24,
        ),

        ProfileInfoTile(
          label: 'Email Address',
          value: email.isEmpty ? 'Not set' : email,
          icon: Icons.email_outlined,
          subtitle: 'Email cannot be changed',
        ),
      ],
    );
  }
}