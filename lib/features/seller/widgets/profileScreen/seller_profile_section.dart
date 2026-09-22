import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/seller/widgets/profileScreen/seller_address_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'seller_profile_menu_item.dart';

// =============================================================
// SELLER PROFILE ACTION SECTIONS
// =============================================================

class SellerProfileSections extends StatelessWidget {
  final bool isLoggingOut;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final DateTime? sellerSince;

  const SellerProfileSections({
    super.key,
    required this.isLoggingOut,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
    required this.sellerSince,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =====================================================
        // ACCOUNT
        // =====================================================
        SellerProfileSection(
          eyebrow: 'Settings',
          title: 'Account',
          child: SellerProfileMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit profile',
            subtitle: 'Update your name, phone number and address.',
            onTap: onEditProfile,
          ),
        ),

        const SizedBox(height: 14),

        // =====================================================
        // SECURITY
        // =====================================================
        SellerProfileSection(
          eyebrow: 'Security',
          title: 'Session',
          child: Column(
            children: [
              SellerProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                title: 'Change password',
                subtitle:
                    'Update your password and keep your seller account secure.',
                onTap: onChangePassword,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.22),
                ),
              ),

              SellerProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Log out',
                subtitle: 'Sign out of this device.',
                destructive: true,
                onTap: isLoggingOut ? null : onLogout,
                trailing: isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // =====================================================
        // FOOTER
        // =====================================================
        SellerProfileFooter(sellerSince: sellerSince),
      ],
    );
  }
}

// =============================================================
// GENERIC SECTION CARD
// =============================================================

class SellerProfileSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;

  const SellerProfileSection({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary.withValues(alpha: 0.58),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}

// =============================================================
// EDIT PROFILE BOTTOM SHEET
// =============================================================

class SellerEditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAddress;

  /// The screen remains responsible for Supabase.
  /// Return true when the save succeeds.
  final Future<bool> Function({
    required String fullName,
    required String phone,
    required String address,
  })
  onSave;

  const SellerEditProfileSheet({
    super.key,
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
    required this.onSave,
  });

  @override
  State<SellerEditProfileSheet> createState() => _SellerEditProfileSheetState();
}

class _SellerEditProfileSheetState extends State<SellerEditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  // =============================================================
  // SELLER ADDRESS PICKER STATE
  // =============================================================

  dynamic _selectedRegion;
  dynamic _selectedProvince;
  dynamic _selectedMunicipality;
  dynamic _selectedBarangay;

  String _detailedAddress = '';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);

    _phoneController = TextEditingController(text: widget.initialPhone);

    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  Future<void> _changeStoreAddress() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    final SellerAddressResult? result = await showSellerAddressPicker(
      context: context,
      initialRegion: _selectedRegion,
      initialProvince: _selectedProvince,
      initialMunicipality: _selectedMunicipality,
      initialBarangay: _selectedBarangay,
      initialDetailedAddress: _detailedAddress,
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _selectedRegion = result.region;
      _selectedProvince = result.province;
      _selectedMunicipality = result.municipality;
      _selectedBarangay = result.barangay;

      _detailedAddress = result.detailedAddress;

      _addressController.text = result.fullAddress;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final String name = _nameController.text.trim();

    final String phone = _phoneController.text.trim();

    final String address = _addressController.text.trim();

    if (name.isEmpty) {
      _showValidationMessage('Please enter your full name.');

      return;
    }

    setState(() {
      _isSaving = true;
    });

    final bool saved = await widget.onSave(
      fullName: name,
      phone: phone,
      address: address,
    );

    if (!mounted) return;

    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.30)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              10,
              AppConstants.defaultPadding,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===============================================
                // HANDLE
                // ===============================================
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ===============================================
                // PREMIUM HEADER
                // ===============================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.manage_accounts_outlined,
                        size: 21,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT DETAILS',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Edit profile',
                            style: TextStyle(
                              fontSize: 21,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            'Keep your seller information accurate and up to date.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSaving
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ===============================================
                // FORM CARD
                // ===============================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    children: [
                      _PremiumProfileField(
                        controller: _nameController,
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 11),

                      _PremiumProfileField(
                        controller: _phoneController,
                        label: 'PHONE NUMBER',
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 11),

                      _SellerStoreAddressField(
                        address: _addressController.text,
                        enabled: !_isSaving,
                        onTap: _changeStoreAddress,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ===============================================
                // INFO
                // ===============================================
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Your email, seller role and profile photo are managed separately.',
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.72,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===============================================
                // SAVE
                // ===============================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.textPrimary,
                      disabledBackgroundColor: AppColors.textPrimary.withValues(
                        alpha: 0.45,
                      ),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _isSaving
                          ? const SizedBox(
                              key: ValueKey('saving'),
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              key: ValueKey('save'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Save changes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
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
}

// =============================================================
// SELLER STORE ADDRESS FIELD
// =============================================================

class _SellerStoreAddressField extends StatelessWidget {
  final String address;
  final bool enabled;
  final VoidCallback onTap;

  const _SellerStoreAddressField({
    required this.address,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAddress = address.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================
        // LABEL
        // =====================================================
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            'STORE ADDRESS',
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: AppColors.textSecondary.withValues(alpha: 0.60),
            ),
          ),
        ),

        const SizedBox(height: 7),

        // =====================================================
        // ADDRESS BUTTON
        // =====================================================
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ===========================================
                  // ICON
                  // ===========================================
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(width: 11),

                  // ===========================================
                  // ADDRESS
                  // ===========================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAddress ? address.trim() : 'Select store address',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: hasAddress
                                ? AppColors.textPrimary
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.55,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          hasAddress
                              ? 'Tap to change store location'
                              : 'Choose city, barangay and exact location',
                          style: TextStyle(
                            fontSize: 8,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.62,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ===========================================
                  // ARROW
                  // ===========================================
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSecondary.withValues(
                      alpha: enabled ? 0.48 : 0.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// =============================================================
// PREMIUM FORM FIELD
// =============================================================

class _PremiumProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  const _PremiumProfileField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
              color: AppColors.textSecondary.withValues(alpha: 0.60),
            ),
          ),
        ),

        const SizedBox(height: 7),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.textPrimary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// PREMIUM LOGOUT CONFIRMATION
// =============================================================

class SellerLogoutDialog extends StatelessWidget {
  const SellerLogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
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
          children: [
            // ===============================================
            // ICON
            // ===============================================
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withValues(alpha: 0.10)),
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 25,
                color: Colors.red.shade700,
              ),
            ),

            const SizedBox(height: 17),

            // ===============================================
            // COPY
            // ===============================================
            const Text(
              'End your session?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You’ll be signed out of your seller account on this device. You can sign back in anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
              ),
            ),

            const SizedBox(height: 22),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.20)),

            const SizedBox(height: 16),

            // ===============================================
            // ACTIONS
            // ===============================================
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.40),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Stay signed in',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: FilledButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// FOOTER
// =============================================================

class SellerProfileFooter extends StatelessWidget {
  final DateTime? sellerSince;

  const SellerProfileFooter({super.key, required this.sellerSince});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/logoSmoothie.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_drink_outlined,
                    size: 15,
                    color: AppColors.textSecondary,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'THE LEGIT SMOOTHIE',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: AppColors.textSecondary,
            ),
          ),

          if (sellerSince != null) ...[
            const SizedBox(height: 4),
            Text(
              'Seller since ${_formatMonthYear(sellerSince!)}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
