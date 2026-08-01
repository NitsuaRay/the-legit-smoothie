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
    _bioController = TextEditingController(
        text: 'Boba enthusiast & regular smoothie lover!');
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
    final secondaryTextColor = isDark
        ? AppColors.cream.withValues(alpha: 0.7)
        : AppColors.greyText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bobaBrown : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Custom Header Section (Replacing AppBar) ---
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.bobaBrown.withValues(alpha: 0.4)
                              : AppColors.greyBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Settings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Manage your personal profile & preferences',
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _isEditing
                            ? (isDark ? AppColors.cream : AppColors.bobaBrown)
                            : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isEditing
                              ? Colors.transparent
                              : (isDark
                                  ? AppColors.bobaBrown.withValues(alpha: 0.4)
                                  : AppColors.greyBorder),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                          color: _isEditing
                              ? (isDark ? AppColors.darkText : AppColors.cardWhite)
                              : (isDark ? AppColors.cream : AppColors.bobaBrown),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- Avatar Banner Section ---
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDark
                                ? AppColors.cream.withValues(alpha: 0.15)
                                : AppColors.bobaBrown.withValues(alpha: 0.1),
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
                                  size: 16,
                                  color: isDark ? AppColors.bobaBrown : AppColors.cardWhite,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cream.withValues(alpha: 0.15)
                              : AppColors.bobaBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'VIP Smoothie Member',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.cream : AppColors.bobaBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // --- Personal Details Container ---
                _buildSectionContainer(
                  context,
                  title: 'Personal Details',
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.alternate_email_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cityController,
                      label: 'City / Location',
                      icon: Icons.location_city_outlined,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _birthdayController,
                      label: 'Birthday',
                      icon: Icons.cake_outlined,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Gender',
                      icon: Icons.wc_outlined,
                      value: _selectedGender,
                      items: _genderOptions,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      cardColor: cardColor,
                      onChanged: _isEditing
                          ? (val) => setState(() => _selectedGender = val!)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio / Note',
                      icon: Icons.note_alt_outlined,
                      enabled: _isEditing,
                      isDark: isDark,
                      maxLines: 2,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- App Preferences Container ---
                _buildSectionContainer(
                  context,
                  title: 'App Preferences',
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    _buildDropdownField(
                      label: 'App Language',
                      icon: Icons.language_rounded,
                      value: _selectedLanguage,
                      items: _languageOptions,
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

                // --- Communication Preferences Container ---
                _buildSectionContainer(
                  context,
                  title: 'Communication & Alerts',
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Email Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Receive updates on promos and receipts via email',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      value: _emailNotifications,
                      activeColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                      onChanged: _isEditing
                          ? (val) => setState(() => _emailNotifications = val)
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(
                      height: 24,
                      color: isDark
                          ? AppColors.bobaBrown.withValues(alpha: 0.3)
                          : AppColors.greyBorder,
                    ),
                    SwitchListTile(
                      title: Text(
                        'SMS Alerts',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Get real-time delivery status updates via SMS',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      value: _smsNotifications,
                      activeColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                      onChanged: _isEditing
                          ? (val) => setState(() => _smsNotifications = val)
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(
                      height: 24,
                      color: isDark
                          ? AppColors.bobaBrown.withValues(alpha: 0.3)
                          : AppColors.greyBorder,
                    ),
                    SwitchListTile(
                      title: Text(
                        'Push Notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Instant updates on your smoothie orders and rewards',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      value: _orderUpdatesPush,
                      activeColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                      onChanged: _isEditing
                          ? (val) => setState(() => _orderUpdatesPush = val)
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                    Divider(
                      height: 24,
                      color: isDark
                          ? AppColors.bobaBrown.withValues(alpha: 0.3)
                          : AppColors.greyBorder,
                    ),
                    SwitchListTile(
                      title: Text(
                        'Exclusive Promos & Offers',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Be the first to know about new flavors and discounts',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      value: _promoAlerts,
                      activeColor: isDark ? AppColors.cream : AppColors.bobaBrown,
                      onChanged: _isEditing
                          ? (val) => setState(() => _promoAlerts = val)
                          : null,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Security Container ---
                _buildSectionContainer(
                  context,
                  title: 'Security & Privacy',
                  cardColor: cardColor,
                  isDark: isDark,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bobaBrown.withValues(alpha: 0.5)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        ),
                      ),
                      title: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      subtitle: Text(
                        'Update your account password regularly',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                      onTap: () {
                        // Handle password reset action
                      },
                    ),
                    Divider(
                      height: 24,
                      color: isDark
                          ? AppColors.bobaBrown.withValues(alpha: 0.3)
                          : AppColors.greyBorder,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.bobaBrown.withValues(alpha: 0.5)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.delete_forever_rounded,
                          size: 20,
                          color: AppColors.error,
                        ),
                      ),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      subtitle: Text(
                        'Permanently delete your account and saved data',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: secondaryTextColor,
                      ),
                      onTap: () {
                        // Handle account deletion flow
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- Save / Action Button ---
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isEditing = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.cream : AppColors.bobaBrown,
                        foregroundColor:
                            isDark ? AppColors.darkText : AppColors.cardWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    required Color cardColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.bobaBrown.withValues(alpha: 0.4)
              : AppColors.greyBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.cream.withValues(alpha: 0.6)
                  : AppColors.bobaBrown,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    int maxLines = 1,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: TextStyle(
        color: primaryTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.cream : AppColors.bobaBrown,
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.bobaBrown.withValues(alpha: enabled ? 0.4 : 0.2)
            : (enabled ? AppColors.cardWhite : AppColors.background),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.bobaBrown.withValues(alpha: 0.6)
                : AppColors.greyBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.bobaBrown.withValues(alpha: 0.3)
                : AppColors.greyBorder,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardColor,
    required ValueChanged<String?>? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.arrow_drop_down_rounded,
          color: isDark ? AppColors.cream : AppColors.bobaBrown),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryTextColor, fontSize: 13),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.cream : AppColors.bobaBrown,
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.bobaBrown.withValues(alpha: _isEditing ? 0.4 : 0.2)
            : (_isEditing ? AppColors.cardWhite : AppColors.background),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.bobaBrown.withValues(alpha: 0.6)
                : AppColors.greyBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.cream : AppColors.bobaBrown,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.bobaBrown.withValues(alpha: 0.3)
                : AppColors.greyBorder,
          ),
        ),
      ),
      dropdownColor: cardColor,
      style: TextStyle(
        color: primaryTextColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}