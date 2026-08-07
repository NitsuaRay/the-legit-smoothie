import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  late TextEditingController _cityController;

  bool _isEditing = false;
  String _selectedGender = 'Prefer not to say';
  String _selectedLanguage = 'English (US)';
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _orderUpdatesPush = true;
  bool _promoAlerts = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  final List<String> _languageOptions = [
    'English (US)',
    'Filipino / Tagalog',
    'Spanish',
    'Japanese'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Valued Customer');
    _emailController = TextEditingController(text: 'customer@legitsmoothie.com');
    _phoneController = TextEditingController(text: '+63 912 345 6789');
    _birthdayController = TextEditingController(text: 'January 15, 1998');
    _bioController =
        TextEditingController(text: 'Boba enthusiast & regular smoothie lover!');
    _usernameController = TextEditingController(text: 'smoothie_lover98');
    _cityController = TextEditingController(text: 'Quezon City, Metro Manila');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.darkText : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor =
        isDark ? AppColors.cream.withValues(alpha: 0.7) : AppColors.greyText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top App Bar ---
                _buildHeader(context, isDark, primaryTextColor),

                const SizedBox(height: 20),

                // --- Centered Profile Header ---
                _buildProfileHeader(isDark, primaryTextColor, secondaryTextColor),

                const SizedBox(height: 20),

                // --- Customer Quick Stats Card ---
                _buildStatsCard(cardColor, isDark, primaryTextColor, secondaryTextColor),

                const SizedBox(height: 24),

                // --- PERSONAL DETAILS SECTION ---
                _buildSectionHeader('PERSONAL DETAILS', isDark),
                const SizedBox(height: 12),
                _buildCardContainer(
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildGroupedField(
                      controller: _nameController,
                      label: 'Full Name',
                      value: _nameController.text,
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _usernameController,
                      label: 'Username',
                      value: '@${_usernameController.text}',
                      icon: Icons.alternate_email_rounded,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _emailController,
                      label: 'Email Address',
                      value: _emailController.text,
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      value: _phoneController.text,
                      icon: Icons.phone_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _cityController,
                      label: 'City / Location',
                      value: _cityController.text,
                      icon: Icons.location_city_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _birthdayController,
                      label: 'Birthday',
                      value: _birthdayController.text,
                      icon: Icons.cake_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedDropdown(
                      label: 'Gender',
                      value: _selectedGender,
                      items: _genderOptions,
                      icon: Icons.wc_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      cardColor: cardColor,
                      onChanged: _isEditing
                          ? (val) => setState(() => _selectedGender = val!)
                          : null,
                    ),
                    _buildDivider(isDark),
                    _buildGroupedField(
                      controller: _bioController,
                      label: 'Bio / Note',
                      value: _bioController.text,
                      icon: Icons.notes_rounded,
                      isDark: isDark,
                      maxLines: 2,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- PREFERENCES SECTION ---
                _buildSectionHeader('PREFERENCES', isDark),
                const SizedBox(height: 12),
                _buildCardContainer(
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildGroupedDropdown(
                      label: 'App Language',
                      value: _selectedLanguage,
                      items: _languageOptions,
                      icon: Icons.language_rounded,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      cardColor: cardColor,
                      onChanged: _isEditing
                          ? (val) => setState(() => _selectedLanguage = val!)
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- NOTIFICATIONS & ALERTS SECTION ---
                _buildSectionHeader('NOTIFICATIONS & ALERTS', isDark),
                const SizedBox(height: 12),
                _buildCardContainer(
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildSwitchTile(
                      title: 'Email Notifications',
                      subtitle: 'Promos, receipts, and order updates',
                      value: _emailNotifications,
                      icon: Icons.mark_email_unread_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onChanged: (val) => setState(() => _emailNotifications = val),
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      title: 'SMS Alerts',
                      subtitle: 'Real-time order delivery updates',
                      value: _smsNotifications,
                      icon: Icons.sms_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onChanged: (val) => setState(() => _smsNotifications = val),
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      title: 'Push Notifications',
                      subtitle: 'Order tracking and reward milestones',
                      value: _orderUpdatesPush,
                      icon: Icons.notifications_none_rounded,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onChanged: (val) => setState(() => _orderUpdatesPush = val),
                    ),
                    _buildDivider(isDark),
                    _buildSwitchTile(
                      title: 'Exclusive Promos',
                      subtitle: 'New flavors, discounts, and offers',
                      value: _promoAlerts,
                      icon: Icons.local_offer_outlined,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onChanged: (val) => setState(() => _promoAlerts = val),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- SECURITY & ACCOUNT SECTION ---
                _buildSectionHeader('SECURITY & ACCOUNT', isDark),
                const SizedBox(height: 12),
                _buildCardContainer(
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildActionTile(
                      title: 'Change Password',
                      subtitle: 'Update your login credentials',
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () {},
                    ),
                    _buildDivider(isDark),
                    _buildActionTile(
                      title: 'Delete Account',
                      subtitle: 'Permanently remove your account & data',
                      icon: Icons.delete_outline_rounded,
                      isDark: isDark,
                      isDanger: true,
                      primaryTextColor: AppColors.error,
                      secondaryTextColor: secondaryTextColor,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- Save Button (Only Visible When Editing) ---
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isEditing = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Account details updated successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_rounded, size: 20),
                      label: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.cream : AppColors.bobaBrown,
                        foregroundColor:
                            isDark ? AppColors.darkText : AppColors.cardWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Clean Top Header (Matching Seller Page) ---
  Widget _buildHeader(
      BuildContext context, bool isDark, Color primaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'Customer Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        IconButton(
          icon: Icon(
            _isEditing ? Icons.close_rounded : Icons.edit_outlined,
            color: primaryTextColor,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
        ),
      ],
    );
  }

  // --- Profile Header (Centered Circle + Title + Tag) ---
  Widget _buildProfileHeader(
      bool isDark, Color primaryText, Color secondaryText) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.cream.withValues(alpha: 0.15)
                      : const Color(0xFFEFE8E1),
                  border: Border.all(
                    color: isDark ? AppColors.cream : AppColors.bobaBrown,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: isDark ? AppColors.cream : AppColors.bobaBrown,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cream : AppColors.bobaBrown,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color:
                          isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.stars_rounded,
              size: 16,
              color: isDark ? AppColors.cream : AppColors.bobaBrown,
            ),
            const SizedBox(width: 4),
            Text(
              'VIP Smoothie Member',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.8)
                    : AppColors.bobaBrown,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Customer Quick Stats Bar (Matching Seller Stat Bar) ---
  Widget _buildStatsCard(
      Color cardColor, bool isDark, Color primaryText, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.3)
              : AppColors.greyBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('4.9 ★', 'Rating', primaryText, secondaryText),
          _buildVerticalDivider(isDark),
          _buildStatColumn('32', 'Orders', primaryText, secondaryText),
          _buildVerticalDivider(isDark),
          _buildStatColumn('450', 'Points', primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      String value, String label, Color primaryText, Color secondaryText) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: secondaryText),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      color: isDark
          ? AppColors.bobaBrown.withValues(alpha: 0.3)
          : AppColors.greyBorder,
    );
  }

  // --- Section Label ---
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  // --- Main Card Wrapper ---
  Widget _buildCardContainer({
    required Color cardColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.3)
              : AppColors.greyBorder,
        ),
      ),
      child: Column(children: children),
    );
  }

  // --- Horizontal Divider Between Items ---
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 48,
      endIndent: 16,
      color: isDark
          ? AppColors.bobaBrown.withValues(alpha: 0.3)
          : AppColors.greyBorder.withValues(alpha: 0.6),
    );
  }

  // --- Seller-Style Grouped Form Row ---
  Widget _buildGroupedField({
    required TextEditingController controller,
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _isEditing
                ? TextFormField(
                    controller: controller,
                    maxLines: maxLines,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      labelStyle:
                          TextStyle(color: secondaryTextColor, fontSize: 12),
                      border: InputBorder.none,
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Please enter $label' : null,
                  )
                : Column(
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
                        value.isNotEmpty ? value : 'Not set',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --- Grouped Dropdown Field ---
  Widget _buildGroupedDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardColor,
    required ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _isEditing
                ? DropdownButtonFormField<String>(
                    value: value,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: label,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      labelStyle:
                          TextStyle(color: secondaryTextColor, fontSize: 12),
                      border: InputBorder.none,
                    ),
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    items: items
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  )
                : Column(
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
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // --- Switch Option Tile ---
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
          ),
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
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: isDark ? AppColors.cream : AppColors.bobaBrown,
            onChanged: _isEditing ? onChanged : null,
          ),
        ],
      ),
    );
  }

  // --- Action Tile (e.g. Security Options) ---
  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    bool isDanger = false,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColors.error.withValues(alpha: 0.1)
                    : (isDark
                        ? AppColors.cream.withValues(alpha: 0.1)
                        : AppColors.bobaBrown.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDanger
                    ? AppColors.error
                    : (isDark ? AppColors.cream : AppColors.bobaBrown),
              ),
            ),
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
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}