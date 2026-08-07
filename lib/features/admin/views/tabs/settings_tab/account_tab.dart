import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AdminAccountView extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminAccountView({super.key, this.onBack});

  @override
  State<AdminAccountView> createState() => _AdminAccountViewState();
}

class _AdminAccountViewState extends State<AdminAccountView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Administrator');
    _emailController = TextEditingController(
      text: 'admin@thelegitsmoothie.com',
    );
    _phoneController = TextEditingController(text: '+63 912 345 6789');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Administrator profile updated successfully.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bobaBrown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;
    final dividerColor = isDark
        ? AppColors.bobaBrown.withValues(alpha: 0.3)
        : AppColors.greyBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: primaryTextColor,
                      size: 20,
                    ),
                    onPressed: widget.onBack ?? () => Navigator.pop(context),
                  ),
                  Text(
                    'Administrator Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                      color: primaryTextColor,
                      size: 22,
                    ),
                    onPressed: () {
                      if (_isEditing) {
                        _saveChanges();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Avatar & Role Section ---
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.cream : AppColors.background,
                        border: Border.all(
                          color: AppColors.bobaBrown,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.bobaBrown,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Super Administrator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.bobaBrown,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Verified System Account • Active',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Quick Stats Overview (4 Metrics cleanly spaced) ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: _cardBoxDecoration(cardColor, dividerColor, isDark),
                child: Row(
                  children: [
                    _buildStatColumn(
                      '99.9%',
                      'System Health',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    _buildVerticalDivider(dividerColor),
                    _buildStatColumn(
                      '142',
                      'Active Sellers',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    _buildVerticalDivider(dividerColor),
                    _buildStatColumn(
                      '3 Devices',
                      'Sessions',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    _buildVerticalDivider(dividerColor),
                    _buildStatColumn(
                      'Optimal',
                      'DB Status',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Personal Information Section ---
              _buildSectionTitle('PERSONAL INFORMATION', isDark),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: _cardBoxDecoration(cardColor, dividerColor, isDark),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      value: _nameController.text,
                      controller: _nameController,
                      isEditing: _isEditing,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email Address',
                      value: _emailController.text,
                      controller: _emailController,
                      isEditing: _isEditing,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                    ),
                    _buildInfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact Number',
                      value: _phoneController.text,
                      controller: _phoneController,
                      isEditing: _isEditing,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: false,
                      dividerColor: dividerColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Organizational Role & Access Section ---
              _buildSectionTitle('ORGANIZATIONAL ROLE & ACCESS', isDark),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardBoxDecoration(cardColor, dividerColor, isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaticInfoItem(
                      icon: Icons.badge_outlined,
                      label: 'Assigned Role',
                      value: 'Super Administrator',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: dividerColor, height: 1),
                    ),
                    _buildStaticInfoItem(
                      icon: Icons.apartment_rounded,
                      label: 'Department',
                      value: 'System Operations & Security',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: dividerColor, height: 1),
                    ),
                    _buildStaticInfoItem(
                      icon: Icons.fingerprint_rounded,
                      label: 'Employee / Admin ID',
                      value: 'ADM-2026-8801',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: dividerColor, height: 1),
                    ),
                    Text(
                      'Granted Access Scopes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPermissionChip('Full DB Access', isDark),
                        _buildPermissionChip('User & Seller Management', isDark),
                        _buildPermissionChip('Financial Audit', isDark),
                        _buildPermissionChip('System Overrides', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- System Access & Security Section ---
              _buildSectionTitle('SECURITY & CONTROLS', isDark),

              Container(
                decoration: _cardBoxDecoration(cardColor, dividerColor, isDark),
                child: Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update account password and credentials',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                      onTap: () {},
                    ),
                    _buildActionItem(
                      icon: Icons.security_rounded,
                      title: 'Two-Factor Authentication',
                      subtitle: 'Authenticator application enabled',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                      trailing: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                      onTap: () {},
                    ),
                    _buildActionItem(
                      icon: Icons.devices_other_rounded,
                      title: 'Active Sessions & Devices',
                      subtitle: 'Manage devices logged into this account',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                      onTap: () {},
                    ),
                    _buildActionItem(
                      icon: Icons.key_rounded,
                      title: 'API & Integration Keys',
                      subtitle: 'View and regenerate administrative API keys',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: true,
                      dividerColor: dividerColor,
                      onTap: () {},
                    ),
                    _buildActionItem(
                      icon: Icons.history_rounded,
                      title: 'Audit Logs & Activity',
                      subtitle: 'View recent administrative actions',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      showDivider: false,
                      dividerColor: dividerColor,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  BoxDecoration _cardBoxDecoration(
    Color cardColor,
    Color borderColor,
    bool isDark,
  ) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String value,
    String label,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color dividerColor) {
    return SizedBox(
      height: 26,
      child: VerticalDivider(
        color: dividerColor,
        thickness: 1,
        width: 1,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool showDivider,
    required Color dividerColor,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.bobaBrown),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    isEditing
                        ? TextField(
                            controller: controller,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(color: dividerColor, height: 1),
      ],
    );
  }

  Widget _buildStaticInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.bobaBrown),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionChip(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bobaBrown.withValues(alpha: 0.4)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.6)
              : AppColors.greyBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.cream : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool showDivider,
    required Color dividerColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.bobaBrown),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  trailing,
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: dividerColor, height: 1),
          ),
      ],
    );
  }
}