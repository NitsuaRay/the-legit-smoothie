import 'package:flutter/material.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal & Account Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _streetController = TextEditingController();

  // Role & Active Status
  String _selectedRole = 'Staff';
  bool _isActive = true;
  bool _obscurePassword = true;
  final List<String> _roles = ['Admin', 'Manager', 'Staff'];

  // Address Selection State using exact `philippines_rpcmb` types
  Region? _selectedRegion;
  Province? _selectedProvince;
  Municipality? _selectedMunicipality;
  String? _selectedBarangay;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Dynamic Color Palette ---
    final primaryAccent = isDarkMode ? AppColors.cream : AppColors.bobaBrown;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDarkMode ? Colors.white : AppColors.darkText);
    final subTextColor =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
        (isDarkMode ? Colors.white70 : AppColors.greyText);
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);
    final borderColor = theme.dividerColor.withOpacity(isDarkMode ? 0.15 : 0.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New User',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Basic Information', subTextColor),

                // --- Full Name ---
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Full Name',
                    Icons.person_outline_rounded,
                    cardBg,
                    borderColor,
                    primaryAccent,
                    subTextColor,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter full name'
                      : null,
                ),
                const SizedBox(height: 12),

                // --- Email ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Email Address',
                    Icons.email_outlined,
                    cardBg,
                    borderColor,
                    primaryAccent,
                    subTextColor,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter email';
                    if (!val.contains('@'))
                      return 'Enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // --- Phone Number ---
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Phone Number',
                    Icons.phone_outlined,
                    cardBg,
                    borderColor,
                    primaryAccent,
                    subTextColor,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter phone number'
                      : null,
                ),
                const SizedBox(height: 12),

                // --- Temporary Password ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Temporary Password',
                    Icons.lock_outline_rounded,
                    cardBg,
                    borderColor,
                    primaryAccent,
                    subTextColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: subTextColor,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Address Details', subTextColor),

                // --- Region Dropdown ---
                _buildDropdownCard(
                  theme: theme,
                  child: PhilippineRegionDropdownView(
                    value: _selectedRegion,
                    onChanged: (Region? value) {
                      setState(() {
                        if (_selectedRegion != value) {
                          _selectedProvince = null;
                          _selectedMunicipality = null;
                          _selectedBarangay = null;
                        }
                        _selectedRegion = value;
                      });
                    },
                  ),
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // --- Province Dropdown ---
                _buildDropdownCard(
                  theme: theme,
                  child: PhilippineProvinceDropdownView(
                    provinces: _selectedRegion?.provinces ?? [],
                    value: _selectedProvince,
                    onChanged: (Province? value) {
                      setState(() {
                        if (_selectedProvince != value) {
                          _selectedMunicipality = null;
                          _selectedBarangay = null;
                        }
                        _selectedProvince = value;
                      });
                    },
                  ),
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // --- City / Municipality Dropdown ---
                _buildDropdownCard(
                  theme: theme,
                  child: PhilippineMunicipalityDropdownView(
                    municipalities: _selectedProvince?.municipalities ?? [],
                    value: _selectedMunicipality,
                    onChanged: (Municipality? value) {
                      setState(() {
                        if (_selectedMunicipality != value) {
                          _selectedBarangay = null;
                        }
                        _selectedMunicipality = value;
                      });
                    },
                  ),
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // --- Barangay Dropdown ---
                _buildDropdownCard(
                  theme: theme,
                  child: PhilippineBarangayDropdownView(
                    barangays: _selectedMunicipality?.barangays ?? [],
                    value: _selectedBarangay,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedBarangay = value;
                      });
                    },
                  ),
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 12),

                // --- Street Address ---
                TextFormField(
                  controller: _streetController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration(
                    'Street Name, Building, House No.',
                    Icons.home_outlined,
                    cardBg,
                    borderColor,
                    primaryAccent,
                    subTextColor,
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter street address'
                      : null,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Role & Account Access', subTextColor),

                // --- Role Selector ---
                _buildDropdownCard(
                  theme: theme,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: primaryAccent,
                      ),
                      style: TextStyle(color: textColor, fontSize: 15),
                      items: _roles
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRole = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // --- Active Status Switch ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Account',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch.adaptive(
                        value: _isActive,
                        activeColor: primaryAccent,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      elevation: 4,
                      shadowColor: primaryAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Create User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkText : Colors.white,
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

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      if (_selectedRegion == null ||
          _selectedProvince == null ||
          _selectedMunicipality == null ||
          _selectedBarangay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all address dropdown selections.'),
          ),
        );
        return;
      }

      // Collect complete payload
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'is_active': _isActive,
        'address': {
          'region': _selectedRegion?.regionName,
          'province': _selectedProvince?.name,
          'municipality': _selectedMunicipality?.name,
          'barangay': _selectedBarangay,
          'street': _streetController.text,
        },
      };

      // Returns true so parent screen reloads user list
      Navigator.pop(context, true);
    }
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required ThemeData theme,
    required Widget child,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: theme.copyWith(canvasColor: theme.cardColor),
        child: child,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon,
    Color cardBg,
    Color borderColor,
    Color accentColor,
    Color subTextColor, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: subTextColor, fontSize: 15),
      prefixIcon: Icon(icon, color: subTextColor, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
