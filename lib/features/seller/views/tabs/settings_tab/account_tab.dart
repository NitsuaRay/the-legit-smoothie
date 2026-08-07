import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class SellerAccountTab extends StatefulWidget {
  const SellerAccountTab({super.key});

  @override
  State<SellerAccountTab> createState() => _SellerAccountTabState();
}

class _SellerAccountTabState extends State<SellerAccountTab> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController _shopNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isEditing = false;
  bool _storeStatus = true; // Store open/closed toggle

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: "The Legit Smoothie Co.");
    _emailController = TextEditingController(text: "seller@legitsmoothie.com");
    _phoneController = TextEditingController(text: "+63 912 345 6789");
    _addressController = TextEditingController(text: "Katipunan Ave, Quezon City, Metro Manila");
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkText : AppColors.background;
    final cardColor = isDark ? AppColors.bobaBrown.withValues(alpha: 0.3) : AppColors.cardWhite;
    final primaryTextColor = isDark ? AppColors.cream : AppColors.darkText;
    final secondaryTextColor = isDark ? AppColors.cream.withValues(alpha: 0.7) : AppColors.greyText;
    final accentColor = isDark ? AppColors.cream : AppColors.bobaBrown;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Seller Profile & Settings',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
              color: accentColor,
            ),
            onPressed: () {
              if (_isEditing) {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop details updated successfully!')),
                  );
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Avatar & Store Toggle ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.cream.withValues(alpha: 0.15)
                                : AppColors.bobaBrown.withValues(alpha: 0.1),
                            border: Border.all(color: accentColor, width: 2),
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            size: 46,
                            color: accentColor,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor,
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
                    Text(
                      _shopNameController.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: isDark ? AppColors.cream : AppColors.bobaBrown,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Smoothie Merchant',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Quick Performance Overview Bar ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Rating', '4.9 ★', primaryTextColor, secondaryTextColor),
                    _buildDivider(isDark),
                    _buildStatItem('Orders', '1,240', primaryTextColor, secondaryTextColor),
                    _buildDivider(isDark),
                    _buildStatItem('Response Rate', '98%', primaryTextColor, secondaryTextColor),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Store Status Switch ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _storeStatus ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              _storeStatus ? 'Currently Accepting Orders' : 'Store is Paused',
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: _storeStatus,
                      activeColor: accentColor,
                      onChanged: (val) {
                        setState(() => _storeStatus = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Section 1: Shop Information ---
              _buildSectionHeader('SHOP INFORMATION', isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.bobaBrown.withValues(alpha: 0.4)
                        : AppColors.greyBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildModernTextField(
                      controller: _shopNameController,
                      label: 'Shop Name',
                      icon: Icons.store_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const Divider(height: 24),
                    _buildModernTextField(
                      controller: _emailController,
                      label: 'Business Email',
                      icon: Icons.email_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const Divider(height: 24),
                    _buildModernTextField(
                      controller: _phoneController,
                      label: 'Contact Number',
                      icon: Icons.phone_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const Divider(height: 24),
                    _buildModernTextField(
                      controller: _addressController,
                      label: 'Store Operating Address',
                      icon: Icons.location_on_rounded,
                      enabled: _isEditing,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- Section 2: Financials & Payouts ---
              _buildSectionHeader('FINANCIALS & PAYOUTS', isDark),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Payout Methods',
                subtitle: 'GCash, BDO Bank • Connected',
                icon: Icons.account_balance_wallet_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                title: 'Tax & Invoicing Information',
                subtitle: 'Manage BIR TIN & Official Receipts',
                icon: Icons.receipt_long_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 28),

              // --- Section 3: Store Management ---
              _buildSectionHeader('STORE SETTINGS', isDark),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Business Hours',
                subtitle: 'Mon - Sun (8:00 AM - 9:00 PM)',
                icon: Icons.access_time_filled_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                title: 'Shipping & Delivery Options',
                subtitle: 'In-house delivery, Lalamove, GrabFood',
                icon: Icons.local_shipping_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 28),

              // --- Section 4: Security & Account ---
              _buildSectionHeader('SECURITY & PREFERENCES', isDark),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'Change Password',
                subtitle: 'Update account security details',
                icon: Icons.lock_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                title: 'Notification Settings',
                subtitle: 'Configure order alerts & sound effects',
                icon: Icons.notifications_active_rounded,
                cardColor: cardColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                isDark: isDark,
                onTap: () {},
              ),

              const SizedBox(height: 32),

              // --- Logout Button ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  label: const Text(
                    'Log Out Seller Account',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    // Handle Logout
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatItem(String label, String value, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark
          ? AppColors.cream.withValues(alpha: 0.2)
          : AppColors.greyBorder,
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.6)
              : AppColors.bobaBrown,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? AppColors.cream.withValues(alpha: 0.8)
              : AppColors.bobaBrown,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.bobaBrown.withValues(alpha: 0.4)
                : AppColors.greyBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cream.withValues(alpha: 0.1)
                    : AppColors.bobaBrown.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.cream : AppColors.bobaBrown,
              ),
            ),
            const SizedBox(width: 16),
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
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}