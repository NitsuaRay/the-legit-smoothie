import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/auth/screens/login_screen.dart';
import 'package:the_legit_smoothie/features/profile/widgets/customer_profile_header.dart';
import 'package:the_legit_smoothie/features/profile/widgets/customer_profile_identity_card.dart';
import 'package:the_legit_smoothie/features/profile/widgets/customer_profile_info_card.dart';
import 'package:the_legit_smoothie/features/profile/widgets/customer_profile_sections.dart';
import 'package:the_legit_smoothie/features/profile/widgets/philippine_address_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const ProfileScreen({super.key, this.showBackButton = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final ImagePicker _imagePicker = ImagePicker();

  static const String _avatarBucket = 'avatars';

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoggingOut = false;
  bool _isUpdatingAvatar = false;

  Map<String, dynamic>? _profile;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // =============================================================
  // LOAD PROFILE
  // =============================================================

  Future<void> _loadProfile({bool refresh = false}) async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });

      return;
    }

    if (refresh && mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final Map<String, dynamic> response = await _supabase
          .from('profiles')
          .select('''
                id,
                full_name,
                phone_number,
                default_address,
                role,
                avatar_url,
                created_at,
                updated_at
              ''')
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _profile = response;
        _isLoading = false;
        _isRefreshing = false;
      });
    } on PostgrestException catch (error) {
      debugPrint('CUSTOMER PROFILE POSTGREST ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');
      debugPrint('Details: ${error.details}');
      debugPrint('Hint: ${error.hint}');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });

      _showMessage('Unable to load profile: ${error.message}', isError: true);
    } catch (error) {
      debugPrint('CUSTOMER PROFILE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });

      _showMessage('Unable to load your profile.', isError: true);
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: isError
              ? Colors.red.shade700
              : AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  // =============================================================
  // AVATAR OPTIONS
  // =============================================================

  Future<void> _showAvatarOptions() async {
    if (_isUpdatingAvatar) return;

    final String currentAvatar =
        _profile?['avatar_url']?.toString().trim() ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
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
                            'PROFILE PHOTO',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.62,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Edit avatar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Take a new photo or choose one from your gallery.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.4,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _AvatarOption(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take a picture',
                  subtitle: 'Use your camera to take a new profile photo.',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 8),

                _AvatarOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from gallery',
                  subtitle: 'Select an existing photo from your device.',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),

                if (currentAvatar.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  _AvatarOption(
                    icon: Icons.delete_outline_rounded,
                    title: 'Remove photo',
                    subtitle: 'Return to the default profile avatar.',
                    destructive: true,
                    onTap: () {
                      Navigator.pop(sheetContext);

                      _removeAvatar();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // PICK + UPLOAD AVATAR
  //
  // IMPORTANT:
  // Uses the SAME approach as the previously working customer
  // avatar implementation:
  //
  // avatars/<user-id>/avatar_<timestamp>.jpg
  // upload()
  // upsert: false
  // =============================================================

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    if (_isUpdatingAvatar) return;

    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedImage == null) {
        return;
      }

      final User? user = _supabase.auth.currentUser;

      if (user == null) {
        _showMessage('You are not signed in.', isError: true);

        return;
      }

      if (mounted) {
        setState(() {
          _isUpdatingAvatar = true;
        });
      }

      final File file = File(pickedImage.path);

      final String extension = pickedImage.path.split('.').last.toLowerCase();

      final String safeExtension =
          ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
          ? extension
          : 'jpg';

      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final String storagePath = '${user.id}/avatar_$timestamp.$safeExtension';

      final String? previousAvatarUrl = _profile?['avatar_url']
          ?.toString()
          .trim();

      await _supabase.storage
          .from(_avatarBucket)
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _getAvatarContentType(safeExtension),
            ),
          );

      final String publicUrl = _supabase.storage
          .from(_avatarBucket)
          .getPublicUrl(storagePath);

      await _supabase
          .from('profiles')
          .update({
            'avatar_url': publicUrl,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      if (!mounted) return;

      setState(() {
        if (_profile != null) {
          _profile!['avatar_url'] = publicUrl;

          _profile!['updated_at'] = DateTime.now().toUtc().toIso8601String();
        }
      });

      _showMessage(
        source == ImageSource.camera
            ? 'Profile photo captured successfully.'
            : 'Profile photo updated successfully.',
      );

      if (previousAvatarUrl != null &&
          previousAvatarUrl.isNotEmpty &&
          previousAvatarUrl != publicUrl) {
        await _deleteAvatarObject(previousAvatarUrl);
      }
    } on StorageException catch (error) {
      debugPrint('CUSTOMER AVATAR STORAGE ERROR');
      debugPrint('Message: ${error.message}');
      debugPrint('Status: ${error.statusCode}');

      if (!mounted) return;

      _showMessage(
        'Unable to upload profile photo: ${error.message}',
        isError: true,
      );
    } on PostgrestException catch (error) {
      debugPrint('CUSTOMER AVATAR PROFILE ERROR: ${error.message}');

      if (!mounted) return;

      _showMessage(
        'Photo uploaded, but your profile could not be updated.',
        isError: true,
      );
    } catch (error) {
      debugPrint('CUSTOMER AVATAR ERROR: $error');

      if (!mounted) return;

      _showMessage('Unable to update profile photo.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
    }
  }

  String _getAvatarContentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'jpeg':
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }

  // =============================================================
  // DELETE AVATAR OBJECT
  // =============================================================

  Future<void> _deleteAvatarObject(String avatarUrl) async {
    try {
      final User? user = _supabase.auth.currentUser;

      if (user == null) return;

      final Uri uri = Uri.parse(avatarUrl);

      if (uri.pathSegments.isEmpty) {
        return;
      }

      final String fileName = uri.pathSegments.last;

      final String storagePath = '${user.id}/$fileName';

      await _supabase.storage.from(_avatarBucket).remove([storagePath]);
    } catch (error) {
      debugPrint('CUSTOMER OLD AVATAR CLEANUP ERROR: $error');
    }
  }

  // =============================================================
  // REMOVE AVATAR
  // =============================================================

  Future<void> _removeAvatar() async {
    if (_isUpdatingAvatar) return;

    final User? user = _supabase.auth.currentUser;

    if (user == null) return;

    final String? currentAvatar = _profile?['avatar_url']?.toString().trim();

    if (mounted) {
      setState(() {
        _isUpdatingAvatar = true;
      });
    }

    try {
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      if (currentAvatar != null && currentAvatar.isNotEmpty) {
        await _deleteAvatarObject(currentAvatar);
      }

      if (!mounted) return;

      setState(() {
        if (_profile != null) {
          _profile!['avatar_url'] = null;
        }
      });

      _showMessage('Profile photo removed.');
    } on PostgrestException catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to remove profile photo: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint('REMOVE CUSTOMER AVATAR ERROR: $error');

      if (!mounted) return;

      _showMessage('Unable to remove profile photo.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvatar = false;
        });
      }
    }
  }

  // =============================================================
  // EDIT PROFILE
  // =============================================================

  Future<void> _showEditProfileSheet() async {
    final Map<String, dynamic>? profile = _profile;

    if (profile == null) return;

    final String initialName = profile['full_name']?.toString().trim() ?? '';

    final String initialPhone =
        profile['phone_number']?.toString().trim() ?? '';

    final String initialAddress =
        profile['default_address']?.toString().trim() ?? '';

    final _CustomerProfileEditResult? result =
        await showModalBottomSheet<_CustomerProfileEditResult>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.40),
          builder: (BuildContext context) {
            return _CustomerEditProfileSheet(
              initialName: initialName,
              initialPhone: initialPhone,
              initialAddress: initialAddress,

              // This is your existing Philippine hierarchy.
              regions: philippineRegions,
            );
          },
        );

    if (result == null) return;

    await _saveProfileChanges(
      fullName: result.fullName,
      phone: result.phone,
      address: result.address,
    );
  }

  // =============================================================
  // SAVE PROFILE
  // =============================================================

  Future<void> _saveProfileChanges({
    required String fullName,
    required String phone,
    required String address,
  }) async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      _showMessage('You are not signed in.', isError: true);

      return;
    }

    try {
      await _supabase
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'phone_number': phone.trim().isEmpty ? null : phone.trim(),
            'default_address': address.trim().isEmpty ? null : address.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      await _loadProfile(refresh: true);

      if (!mounted) return;

      _showMessage('Profile updated successfully.');
    } on PostgrestException catch (error) {
      debugPrint('UPDATE CUSTOMER PROFILE ERROR: ${error.message}');

      if (!mounted) return;

      _showMessage('Unable to update profile: ${error.message}', isError: true);
    } catch (error) {
      debugPrint('UPDATE CUSTOMER PROFILE ERROR: $error');

      if (!mounted) return;

      _showMessage('Unable to update profile.', isError: true);
    }
  }

  // =============================================================
  // LOGOUT CONFIRMATION
  // =============================================================

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (BuildContext dialogContext) {
        return const _CustomerLogoutDialog();
      },
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  // =============================================================
  // LOGOUT
  // =============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Sign out locally first.
      await _supabase.auth.signOut(scope: SignOutScope.local);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      debugPrint('Customer LOGOUT ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      _showMessage('Unable to log out. Please try again.', isError: true);
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(BuildContext context) {
    final User? user = _supabase.auth.currentUser;

    final String rawName = _profile?['full_name']?.toString().trim() ?? '';

    final String name = rawName.isEmpty ? 'Customer' : rawName;

    final String phone = _profile?['phone_number']?.toString().trim() ?? '';

    final String address =
        _profile?['default_address']?.toString().trim() ?? '';

    final String rawAvatar = _profile?['avatar_url']?.toString().trim() ?? '';

    final String? avatarUrl = rawAvatar.isEmpty ? null : rawAvatar;

    final String email = user?.email?.trim() ?? '';

    final DateTime? customerSince = DateTime.tryParse(
      _profile?['created_at']?.toString() ?? '',
    )?.toLocal();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.textPrimary),
              )
            : RefreshIndicator(
                color: AppColors.textPrimary,
                onRefresh: () {
                  return _loadProfile(refresh: true);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // =========================================
                    // HEADER
                    // =========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          22,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: CustomerProfileHeader(
                          showBackButton: widget.showBackButton,
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                          isRefreshing: _isRefreshing,
                          onRefresh: () {
                            _loadProfile(refresh: true);
                          },
                        ),
                      ),
                    ),

                    // =========================================
                    // IDENTITY
                    // =========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          20,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: CustomerProfileIdentityCard(
                          name: name,
                          email: email,
                          avatarUrl: avatarUrl,
                          onEditAvatar: _showAvatarOptions,
                        ),
                      ),
                    ),

                    // =========================================
                    // CONTACT
                    // =========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          14,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: CustomerProfileInfoCard(
                          items: [
                            CustomerProfileInfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Phone number',
                              value: phone,
                            ),
                            CustomerProfileInfoItem(
                              icon: Icons.location_on_outlined,
                              label: 'Delivery address',
                              value: address,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // =========================================
                    // SETTINGS + SECURITY + FOOTER
                    // =========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          14,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: CustomerProfileSections(
                          onEditProfile: _showEditProfileSheet,
                          onLogout: _confirmLogout,
                          isLoggingOut: _isLoggingOut,
                          customerSince: customerSince,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  ],
                ),
              ),
      ),
    );
  }
}

// ============================================================================
// EDIT RESULT
// ============================================================================

class _CustomerProfileEditResult {
  final String fullName;
  final String phone;
  final String address;

  const _CustomerProfileEditResult({
    required this.fullName,
    required this.phone,
    required this.address,
  });
}

// ============================================================================
// PREMIUM EDIT PROFILE SHEET
// ============================================================================

class _CustomerEditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialAddress;

  final List<dynamic> regions;

  const _CustomerEditProfileSheet({
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
    required this.regions,
  });

  @override
  State<_CustomerEditProfileSheet> createState() =>
      _CustomerEditProfileSheetState();
}

class _CustomerEditProfileSheetState extends State<_CustomerEditProfileSheet> {
  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  late final TextEditingController _detailedAddressController;

  String _addressPreview = '';

  dynamic _selectedRegion;
  dynamic _selectedProvince;
  dynamic _selectedMunicipality;
  dynamic _selectedBarangay;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName);

    _phoneController = TextEditingController(text: widget.initialPhone);

    _detailedAddressController = TextEditingController();

    _addressPreview = widget.initialAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _detailedAddressController.dispose();

    super.dispose();
  }

  // =============================================================
  // ADDRESS
  // =============================================================
  Future<void> _openAddressPicker() async {
    final PhilippineAddressResult? selection =
        await showPhilippineAddressPicker(
          context: context,
          regions: widget.regions,
          initialRegion: _selectedRegion,
          initialProvince: _selectedProvince,
          initialMunicipality: _selectedMunicipality,
          initialBarangay: _selectedBarangay,
          initialDetailedAddress: _detailedAddressController.text,
        );

    if (selection == null) {
      return;
    }

    setState(() {
      _selectedRegion = selection.region;

      _selectedProvince = selection.province;

      _selectedMunicipality = selection.municipality;

      _selectedBarangay = selection.barangay;

      _detailedAddressController.text = selection.detailedAddress;

      _addressPreview = selection.fullAddress;
    });
  }

  // =============================================================
  // SAVE
  // =============================================================

  void _save() {
    final String fullName = _nameController.text.trim();

    final String phone = _phoneController.text.trim();

    if (fullName.isEmpty) {
      _showValidation('Please enter your full name.');

      return;
    }

    if (phone.isNotEmpty) {
      final String digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');

      if (digits.length < 10) {
        _showValidation('Please enter a valid phone number.');

        return;
      }
    }

    Navigator.of(context).pop(
      _CustomerProfileEditResult(
        fullName: fullName,
        phone: phone,
        address: _addressPreview.trim(),
      ),
    );
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =============================================================
  // BUILD
  // =============================================================

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
                // HEADER
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
                            'Update your personal and delivery information.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.4,
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
                        onTap: () {
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
                // PERSONAL INFORMATION
                // ===============================================
                _PremiumSectionLabel(
                  eyebrow: 'Personal',
                  title: 'Personal information',
                ),

                const SizedBox(height: 11),

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
                      _PremiumTextField(
                        controller: _nameController,
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                      ),

                      const SizedBox(height: 12),

                      _PremiumTextField(
                        controller: _phoneController,
                        label: 'PHONE NUMBER',
                        hint: '09XX XXX XXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===============================================
                // DELIVERY ADDRESS
                // ===============================================
                _PremiumSectionLabel(
                  eyebrow: 'Delivery',
                  title: 'Delivery address',
                ),

                const SizedBox(height: 11),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openAddressPicker,
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DELIVERY ADDRESS',
                                  style: TextStyle(
                                    fontSize: 6.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.9,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.60,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  _addressPreview.trim().isEmpty
                                      ? 'Set your delivery address'
                                      : _addressPreview,
                                  style: TextStyle(
                                    fontSize: 10,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: _addressPreview.trim().isEmpty
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Region, province, city / municipality and barangay',
                                  style: TextStyle(
                                    fontSize: 8,
                                    height: 1.3,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.62,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

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
                          'Your email and profile photo are managed separately.',
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1.4,
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
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.textPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Row(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ============================================================================
// PREMIUM SECTION LABEL
// ============================================================================

class _PremiumSectionLabel extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _PremiumSectionLabel({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.05,
            color: AppColors.textSecondary.withValues(alpha: 0.58),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PREMIUM TEXT FIELD
// ============================================================================

class _PremiumTextField extends StatelessWidget {
  final TextEditingController controller;

  final String label;
  final String hint;
  final IconData icon;

  final TextInputType? keyboardType;

  final TextCapitalization textCapitalization;

  const _PremiumTextField({
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

// ============================================================================
// AVATAR OPTION
// ============================================================================

class _AvatarOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final VoidCallback onTap;

  final bool destructive;

  const _AvatarOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground = destructive
        ? Colors.red.shade700
        : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: destructive
                  ? Colors.red.withValues(alpha: 0.12)
                  : AppColors.border.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: destructive
                      ? Colors.red.withValues(alpha: 0.06)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: foreground),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 8.5,
                        height: 1.35,
                        color: AppColors.textSecondary.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: AppColors.textSecondary.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PREMIUM LOGOUT DIALOG
// ============================================================================

class _CustomerLogoutDialog extends StatelessWidget {
  const _CustomerLogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
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
              'You’ll be signed out of your customer account on this device. You can sign back in anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.5,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
              ),
            ),

            const SizedBox(height: 22),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.20)),

            const SizedBox(height: 16),

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
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
