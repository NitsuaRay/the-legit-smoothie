import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/shared/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/screens/login_screen.dart';
import '../../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    _fullNameController.text = user.userMetadata?['full_name'] ?? '';

    try {
      final data = await supabase
          .from('profiles')
          .select('phone_number, default_address, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        if (data['full_name'] != null &&
            (data['full_name'] as String).isNotEmpty) {
          _fullNameController.text = data['full_name'];
        }
        _phoneController.text = data['phone_number'] ?? '';
        _addressController.text = data['default_address'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Helper to persist changes to Supabase ---
  Future<void> _saveField({
    required String fieldName,
    required Future<void> Function() onSave,
  }) async {
    try {
      await onSave();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fieldName updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update $fieldName: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // --- 1. Edit Full Name Dialog ---
  void _showNameDialog() {
    final formKey = GlobalKey<FormState>();
    final tempController = TextEditingController(
      text: _fullNameController.text,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Icon & Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Full Name',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Enter your primary full name',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Form Field
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: tempController,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.background.withValues(
                              alpha: 0.5,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Name cannot be empty'
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setDialogState(() => isSaving = true);
                                        final newName = tempController.text
                                            .trim();
                                        final user = supabase.auth.currentUser;

                                        if (user != null) {
                                          await _saveField(
                                            fieldName: 'Full Name',
                                            onSave: () async {
                                              await supabase.auth.updateUser(
                                                UserAttributes(
                                                  data: {'full_name': newName},
                                                ),
                                              );
                                              await supabase
                                                  .from('profiles')
                                                  .upsert({
                                                    'id': user.id,
                                                    'full_name': newName,
                                                    'updated_at': DateTime.now()
                                                        .toIso8601String(),
                                                  });
                                              _fullNameController.text =
                                                  newName;
                                            },
                                          );
                                        }

                                        if (dialogContext.mounted) {
                                          Navigator.pop(dialogContext);
                                        }
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Name',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. Edit Phone Dialog (intl_phone_number_input) ---
  void _showPhoneDialog() {
    final formKey = GlobalKey<FormState>();
    PhoneNumber phoneNumber = PhoneNumber(
      isoCode: 'PH',
      phoneNumber: _phoneController.text,
    );
    String rawPhone = _phoneController.text;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Icon & Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.phone_iphone_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Phone Number',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Enter your primary mobile number',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Input Form Field
                      Form(
                        key: formKey,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.copyWith(
                              bodyMedium: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (phone) {
                              rawPhone = phone.phoneNumber ?? '';
                            },
                            initialValue: phoneNumber,
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              useEmoji: true,
                              setSelectorButtonAsPrefixIcon: true,
                              leadingPadding: 12,
                            ),
                            countries: const ['PH'],
                            formatInput: true,
                            keyboardType: TextInputType.phone,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            inputDecoration: InputDecoration(
                              labelText: 'Mobile Number',
                              labelStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.background.withValues(
                                alpha: 0.5,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        setDialogState(() => isSaving = true);
                                        final user = supabase.auth.currentUser;

                                        if (user != null) {
                                          await _saveField(
                                            fieldName: 'Phone Number',
                                            onSave: () async {
                                              await supabase
                                                  .from('profiles')
                                                  .upsert({
                                                    'id': user.id,
                                                    'phone_number': rawPhone,
                                                    'updated_at': DateTime.now()
                                                        .toIso8601String(),
                                                  });
                                              _phoneController.text = rawPhone;
                                            },
                                          );
                                        }

                                        if (dialogContext.mounted) {
                                          Navigator.pop(dialogContext);
                                        }
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Phone',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddressDialog() {
    final formKey = GlobalKey<FormState>();
    final streetController = TextEditingController();

    // philippines_rpcmb uses the global philippineRegions list.
    final List<Region> regions = philippineRegions;

    // Default to NCR.
    Region selectedRegion = regions.firstWhere(
      (r) => r.regionName.toLowerCase() == 'ncr',
      orElse: () => regions.first,
    );

    // Find the NCR province/district containing Quezon City.
    List<Province> provinces = selectedRegion.provinces;

    Province? selectedProvince;

    for (final province in provinces) {
      final hasQuezonCity = province.municipalities.any(
        (municipality) =>
            municipality.name.toLowerCase().contains('quezon city'),
      );

      if (hasQuezonCity) {
        selectedProvince = province;
        break;
      }
    }

    // Fallback to first province.
    selectedProvince ??= provinces.isNotEmpty ? provinces.first : null;

    // Get municipalities from selected province.
    List<Municipality> municipalities = selectedProvince?.municipalities ?? [];

    // Default to Quezon City.
    Municipality? selectedMunicipality;

    for (final municipality in municipalities) {
      if (municipality.name.toLowerCase().contains('quezon city')) {
        selectedMunicipality = municipality;
        break;
      }
    }

    // Fallback to first municipality.
    selectedMunicipality ??= municipalities.isNotEmpty
        ? municipalities.first
        : null;

    // philippines_rpcmb uses String for barangays.
    List<String> barangays = selectedMunicipality?.barangays ?? [];

    String? selectedBarangay = barangays.isNotEmpty ? barangays.first : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        // Premium Input Field Decoration Helper
        InputDecoration buildInputDecoration({
          required String labelText,
          required IconData prefixIcon,
        }) {
          return InputDecoration(
            labelText: labelText,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            prefixIcon: Icon(
              prefixIcon,
              size: 20,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.6),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Icon & Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Update Address',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Select your location details below',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Form Fields Section
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Region ---
                            DropdownButtonFormField<Region>(
                              initialValue: selectedRegion,
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: buildInputDecoration(
                                labelText: 'Region',
                                prefixIcon: Icons.map_outlined,
                              ),
                              items: regions.map((region) {
                                return DropdownMenuItem<Region>(
                                  value: region,
                                  child: Text(
                                    region.regionName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setDialogState(() {
                                  selectedRegion = value;
                                  provinces = selectedRegion.provinces;
                                  selectedProvince = null;

                                  for (final province in provinces) {
                                    final hasQuezonCity = province
                                        .municipalities
                                        .any(
                                          (m) => m.name.toLowerCase().contains(
                                            'quezon city',
                                          ),
                                        );
                                    if (hasQuezonCity) {
                                      selectedProvince = province;
                                      break;
                                    }
                                  }

                                  selectedProvince ??= provinces.isNotEmpty
                                      ? provinces.first
                                      : null;
                                  municipalities =
                                      selectedProvince?.municipalities ?? [];
                                  selectedMunicipality = null;

                                  for (final municipality in municipalities) {
                                    if (municipality.name
                                        .toLowerCase()
                                        .contains('quezon city')) {
                                      selectedMunicipality = municipality;
                                      break;
                                    }
                                  }

                                  selectedMunicipality ??=
                                      municipalities.isNotEmpty
                                      ? municipalities.first
                                      : null;
                                  barangays =
                                      selectedMunicipality?.barangays ?? [];
                                  selectedBarangay = barangays.isNotEmpty
                                      ? barangays.first
                                      : null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // --- Province / District ---
                            if (provinces.isNotEmpty) ...[
                              DropdownButtonFormField<Province>(
                                initialValue: selectedProvince,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: buildInputDecoration(
                                  labelText: 'Province / District',
                                  prefixIcon: Icons.explore_outlined,
                                ),
                                items: provinces.map((province) {
                                  return DropdownMenuItem<Province>(
                                    value: province,
                                    child: Text(
                                      province.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setDialogState(() {
                                    selectedProvince = value;
                                    municipalities =
                                        selectedProvince!.municipalities;
                                    selectedMunicipality =
                                        municipalities.isNotEmpty
                                        ? municipalities.first
                                        : null;
                                    barangays =
                                        selectedMunicipality?.barangays ?? [];
                                    selectedBarangay = barangays.isNotEmpty
                                        ? barangays.first
                                        : null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- City / Municipality ---
                            if (municipalities.isNotEmpty) ...[
                              DropdownButtonFormField<Municipality>(
                                initialValue: selectedMunicipality,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: buildInputDecoration(
                                  labelText: 'City / Municipality',
                                  prefixIcon: Icons.location_city_outlined,
                                ),
                                items: municipalities.map((municipality) {
                                  return DropdownMenuItem<Municipality>(
                                    value: municipality,
                                    child: Text(
                                      municipality.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setDialogState(() {
                                    selectedMunicipality = value;
                                    barangays = selectedMunicipality!.barangays;
                                    selectedBarangay = barangays.isNotEmpty
                                        ? barangays.first
                                        : null;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- Barangay ---
                            if (barangays.isNotEmpty) ...[
                              DropdownButtonFormField<String>(
                                initialValue: selectedBarangay,
                                isExpanded: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: buildInputDecoration(
                                  labelText: 'Barangay',
                                  prefixIcon: Icons.holiday_village_outlined,
                                ),
                                items: barangays.map((barangay) {
                                  return DropdownMenuItem<String>(
                                    value: barangay,
                                    child: Text(
                                      barangay,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setDialogState(() {
                                    selectedBarangay = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- Street / House Details ---
                            TextFormField(
                              controller: streetController,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: buildInputDecoration(
                                labelText: 'House No., Street Name, Building',
                                prefixIcon: Icons.home_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter street details';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: AppColors.border.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }

                                      setDialogState(() => isSaving = true);

                                      final formattedParts = <String>[
                                        streetController.text.trim(),
                                        if (selectedBarangay != null)
                                          'Brgy. $selectedBarangay',
                                        if (selectedMunicipality != null)
                                          selectedMunicipality!.name,
                                        if (selectedProvince != null)
                                          selectedProvince!.name,
                                        selectedRegion.regionName,
                                      ];

                                      final fullAddress = formattedParts
                                          .where((part) => part.isNotEmpty)
                                          .join(', ');

                                      final user = supabase.auth.currentUser;

                                      if (user != null) {
                                        await _saveField(
                                          fieldName: 'Address',
                                          onSave: () async {
                                            await supabase
                                                .from('profiles')
                                                .upsert({
                                                  'id': user.id,
                                                  'default_address':
                                                      fullAddress,
                                                  'updated_at': DateTime.now()
                                                      .toIso8601String(),
                                                });

                                            _addressController.text =
                                                fullAddress;
                                          },
                                        );
                                      }

                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save Address',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.border.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Destructive Accent Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Confirm session termination',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirmation Prompt Body
                const Text(
                  'Are you sure you want to log out? You will need to sign back in to access your profile and saved data.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      },
    );

    if (confirm != true) return;

    try {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    final fullName = _fullNameController.text.isNotEmpty
        ? _fullNameController.text
        : (user?.userMetadata?['full_name'] ?? 'Smoothie Lover');

    final email = user?.email ?? '';

    // ----------------------------------------
    // Display-only phone formatting
    // ----------------------------------------
    String formatPhoneNumber(String phone) {
      final value = phone.trim();

      if (value.isEmpty) return 'Not set';

      // +639562972161 -> +63 956 297 2161
      if (value.startsWith('+63') && value.length == 13) {
        return '${value.substring(0, 3)} '
            '${value.substring(3, 6)} '
            '${value.substring(6, 9)} '
            '${value.substring(9)}';
      }

      // 09562972161 -> 0956 297 2161
      if (value.startsWith('09') && value.length == 11) {
        return '${value.substring(0, 4)} '
            '${value.substring(4, 7)} '
            '${value.substring(7)}';
      }

      return value;
    }

    // ----------------------------------------
    // Display-only address formatting
    // ----------------------------------------
    String formatDeliveryAddress(String address) {
      final value = address.trim();

      if (value.isEmpty) return 'Not set';

      String formatted = value;

      // Make capitalization more user-friendly.
      formatted = formatted.replaceAll(
        'NATIONAL CAPITAL REGION - SECOND DISTRICT',
        'Metro Manila',
      );

      formatted = formatted.replaceAll(', NCR', '');

      // Clean up possible duplicate commas/spaces.
      formatted = formatted
          .replaceAll(RegExp(r',\s*,+'), ',')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      return formatted;
    }

    final displayPhone = formatPhoneNumber(_phoneController.text);

    final displayAddress = formatDeliveryAddress(_addressController.text);

    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: MainAppBar(
        showLogo: false,
        showBackButton: false,
        titleWidget: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.textPrimary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Account Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: AppColors.surface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Manage your account details and preferences',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // ==========================================
                  // PROFILE HEADER
                  // ==========================================
                  Center(
                    child: Column(
                      children: [
                        // Profile Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.primaryAccent
                                  .withValues(alpha: 0.18),
                              child: Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            // Small status indicator
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Full Name
                        Text(
                          fullName.isNotEmpty ? fullName : 'User',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        // Email
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.85,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const SizedBox(height: 10),

                        // Account type / status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Customer Account',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(height: 20),

                  // ==========================================
                  // USER INFORMATION
                  // ==========================================
                  _buildSectionContainer(
                    title: 'User Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoTile(
                        label: 'Full Name',
                        value: _fullNameController.text.isEmpty
                            ? 'Not set'
                            : _fullNameController.text,
                        icon: Icons.badge_outlined,
                        onEdit: _showNameDialog,
                      ),

                      const Divider(color: AppColors.border, height: 24),

                      _buildInfoTile(
                        label: 'Email Address',
                        value: email.isEmpty ? 'Not set' : email,
                        icon: Icons.email_outlined,
                        subtitle: 'Email cannot be changed',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // DELIVERY INFORMATION
                  // ==========================================
                  _buildSectionContainer(
                    title: 'Delivery Information',
                    icon: Icons.local_shipping_outlined,

                    children: [
                      // Small subtitle
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
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

                      // PHONE
                      _buildInfoTile(
                        label: 'Default Phone Number',
                        value: displayPhone,
                        icon: Icons.phone_outlined,
                        onEdit: _showPhoneDialog,
                      ),

                      const Divider(color: AppColors.border, height: 24),

                      // ADDRESS
                      _buildInfoTile(
                        label: 'Default Delivery Address',
                        value: displayAddress,
                        icon: Icons.location_on_outlined,
                        onEdit: _showAddressDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // LOGOUT
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _handleSignOut,

                      icon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),

                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: AppColors.error,
                        elevation: 0,

                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onEdit,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: value == 'Not set'
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: onEdit,
            tooltip: 'Edit $label',
          ),
      ],
    );
  }
}
