import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/auth/screens/login_screen.dart';
import 'package:the_legit_smoothie/widgets/change_password_dialog.dart';
import 'package:the_legit_smoothie/features/seller/widgets/profileScreen/seller_profile_header.dart';
import 'package:the_legit_smoothie/features/seller/widgets/profileScreen/seller_profile_identity_card.dart';
import 'package:the_legit_smoothie/features/seller/widgets/profileScreen/seller_profile_info_card.dart';
import 'package:the_legit_smoothie/features/seller/widgets/profileScreen/seller_profile_section.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoggingOut = false;

  Map<String, dynamic>? _profile;

  final ImagePicker _imagePicker = ImagePicker();

  bool _isUpdatingAvatar = false;

  // =============================================================
  // LIFECYCLE
  // =============================================================

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _showChangePassword() async {
    final bool? changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const ChangePasswordDialog();
      },
    );

    if (!mounted || changed != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password changed successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      debugPrint('SELLER PROFILE POSTGREST ERROR');
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
      debugPrint('SELLER PROFILE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });

      _showMessage('Unable to load your profile.', isError: true);
    }
  }

  Future<void> _showAvatarOptions() async {
    if (_isUpdatingAvatar) return;

    final String currentAvatar =
        _profile?['avatar_url']?.toString().trim() ?? '';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HANDLE
                // =================================================
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // HEADER
                // =================================================
                const Text(
                  'PROFILE PHOTO',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
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
                    fontSize: 9.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.72),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // CAMERA
                // =================================================
                _AvatarOption(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take a picture',
                  subtitle: 'Use your camera to take a new photo.',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickAndUploadAvatar(ImageSource.camera);
                  },
                ),

                const SizedBox(height: 8),

                // =================================================
                // GALLERY
                // =================================================
                _AvatarOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from gallery',
                  subtitle: 'Select an existing photo from your device.',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickAndUploadAvatar(ImageSource.gallery);
                  },
                ),

                // =================================================
                // REMOVE
                // =================================================
                if (currentAvatar.isNotEmpty) ...[
                  const SizedBox(height: 8),

                  _AvatarOption(
                    icon: Icons.delete_outline_rounded,
                    title: 'Remove photo',
                    subtitle: 'Use the default profile avatar.',
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

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    if (_isUpdatingAvatar) return;

    try {
      // =========================================================
      // PICK IMAGE
      // =========================================================

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

      // =========================================================
      // CURRENT USER
      // =========================================================

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

      // =========================================================
      // FILE
      // =========================================================

      final File file = File(pickedImage.path);

      final String extension = pickedImage.path.split('.').last.toLowerCase();

      final String safeExtension =
          ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
          ? extension
          : 'jpg';

      // =========================================================
      // UNIQUE STORAGE PATH
      // Same strategy as customer profile.
      // =========================================================

      final int timestamp = DateTime.now().millisecondsSinceEpoch;

      final String storagePath = '${user.id}/avatar_$timestamp.$safeExtension';

      debugPrint('SELLER AVATAR USER: ${user.id}');

      debugPrint('SELLER AVATAR PATH: $storagePath');

      // =========================================================
      // REMEMBER PREVIOUS AVATAR
      // =========================================================

      final String? previousAvatarUrl = _profile?['avatar_url']
          ?.toString()
          .trim();

      // =========================================================
      // UPLOAD
      // =========================================================

      await _supabase.storage
          .from('avatars')
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',

              // IMPORTANT:
              // Match customer implementation.
              upsert: false,

              contentType: _getAvatarContentType(safeExtension),
            ),
          );

      // =========================================================
      // PUBLIC URL
      // =========================================================

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(storagePath);

      debugPrint('SELLER AVATAR URL: $publicUrl');

      // =========================================================
      // UPDATE PROFILE
      // =========================================================

      await _supabase
          .from('profiles')
          .update({
            'avatar_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      // =========================================================
      // UPDATE LOCAL STATE
      // =========================================================

      if (!mounted) return;

      setState(() {
        if (_profile != null) {
          _profile!['avatar_url'] = publicUrl;

          _profile!['updated_at'] = DateTime.now().toIso8601String();
        }
      });

      _showMessage(
        source == ImageSource.camera
            ? 'Profile photo captured successfully.'
            : 'Profile photo updated successfully.',
      );

      // =========================================================
      // DELETE OLD AVATAR
      // Do this AFTER the new avatar succeeds.
      // =========================================================

      if (previousAvatarUrl != null &&
          previousAvatarUrl.isNotEmpty &&
          previousAvatarUrl != publicUrl) {
        await _deleteOldAvatar(previousAvatarUrl);
      }
    } on StorageException catch (error) {
      debugPrint('SELLER AVATAR STORAGE ERROR');
      debugPrint('Message: ${error.message}');
      debugPrint('Status: ${error.statusCode}');

      if (!mounted) return;

      _showMessage(
        'Unable to upload profile photo: ${error.message}',
        isError: true,
      );
    } on PostgrestException catch (error) {
      debugPrint('SELLER AVATAR PROFILE ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');

      if (!mounted) return;

      _showMessage(
        'Photo uploaded, but your profile could not be updated.',
        isError: true,
      );
    } catch (error) {
      debugPrint('SELLER AVATAR ERROR: $error');

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

  Future<void> _deleteOldAvatar(String avatarUrl) async {
    try {
      final User? user = _supabase.auth.currentUser;

      if (user == null) return;

      final Uri uri = Uri.parse(avatarUrl);

      if (uri.pathSegments.isEmpty) {
        return;
      }

      final String fileName = uri.pathSegments.last;

      final String oldStoragePath = '${user.id}/$fileName';

      debugPrint('DELETING OLD SELLER AVATAR: $oldStoragePath');

      await _supabase.storage.from('avatars').remove([oldStoragePath]);
    } catch (error) {
      // Avatar update already succeeded.
      // Old-file cleanup should not break the update.
      debugPrint('OLD SELLER AVATAR CLEANUP FAILED: $error');
    }
  }

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
      // =========================================================
      // CLEAR PROFILE FIRST
      // =========================================================

      await _supabase
          .from('profiles')
          .update({
            'avatar_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      // =========================================================
      // DELETE STORAGE OBJECT
      // =========================================================

      if (currentAvatar != null && currentAvatar.isNotEmpty) {
        await _deleteOldAvatar(currentAvatar);
      }

      // =========================================================
      // LOCAL STATE
      // =========================================================

      if (!mounted) return;

      setState(() {
        if (_profile != null) {
          _profile!['avatar_url'] = null;

          _profile!['updated_at'] = DateTime.now().toIso8601String();
        }
      });

      _showMessage('Profile photo removed.');
    } on PostgrestException catch (error) {
      debugPrint('REMOVE SELLER AVATAR PROFILE ERROR: ${error.message}');

      if (!mounted) return;

      _showMessage(
        'Unable to remove profile photo: ${error.message}',
        isError: true,
      );
    } catch (error) {
      debugPrint('REMOVE SELLER AVATAR ERROR: $error');

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
  // MESSAGE
  // =============================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =============================================================
  // EDIT PROFILE
  // =============================================================

  Future<void> _editProfile() async {
    final Map<String, dynamic>? profile = _profile;

    if (profile == null) return;

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (BuildContext context) {
        return SellerEditProfileSheet(
          initialName: profile['full_name']?.toString() ?? '',
          initialPhone: profile['phone_number']?.toString() ?? '',
          initialAddress: profile['default_address']?.toString() ?? '',
          onSave: _saveProfileChanges,
        );
      },
    );

    if (saved == true) {
      await _loadProfile(refresh: true);

      _showMessage('Profile updated successfully.');
    }
  }

  Future<bool> _saveProfileChanges({
    required String fullName,
    required String phone,
    required String address,
  }) async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      await _supabase
          .from('profiles')
          .update({
            'full_name': fullName,
            'phone_number': phone.isEmpty ? null : phone,
            'default_address': address.isEmpty ? null : address,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);

      return true;
    } on PostgrestException catch (error) {
      debugPrint('UPDATE SELLER PROFILE POSTGREST ERROR');
      debugPrint('Code: ${error.code}');
      debugPrint('Message: ${error.message}');

      if (mounted) {
        _showMessage(
          'Unable to update profile: ${error.message}',
          isError: true,
        );
      }

      return false;
    } catch (error) {
      debugPrint('UPDATE SELLER PROFILE ERROR: $error');

      if (mounted) {
        _showMessage('Unable to update profile.', isError: true);
      }

      return false;
    }
  }

  // =============================================================
  // LOGOUT CONFIRMATION
  // =============================================================

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (BuildContext context) {
        return const SellerLogoutDialog();
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
      debugPrint('SELLER LOGOUT ERROR: $error');

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

    final String name = rawName.isEmpty ? 'Seller' : rawName;

    final String rawRole = _profile?['role']?.toString().trim() ?? '';

    final String role = rawRole.isEmpty ? 'Seller' : rawRole;

    final String phone = _profile?['phone_number']?.toString().trim() ?? '';

    final String address =
        _profile?['default_address']?.toString().trim() ?? '';

    final String rawAvatar = _profile?['avatar_url']?.toString().trim() ?? '';

    final DateTime? sellerSince = DateTime.tryParse(
      _profile?['created_at']?.toString() ?? '',
    )?.toLocal();

    final String? avatarUrl = rawAvatar.isEmpty ? null : rawAvatar;

    final String email = user?.email?.trim() ?? '';

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
                        child: SellerProfileHeader(
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
                        child: SellerProfileIdentityCard(
                          name: name,
                          role: role,
                          email: email,
                          avatarUrl: avatarUrl,
                          onEditAvatar: _showAvatarOptions,
                        ),
                      ),
                    ),

                    // =========================================
                    // CONTACT
                    // Phone + address only.
                    // Email is already in identity card.
                    // =========================================
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          14,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: SellerProfileInfoCard(
                          eyebrow: 'Contact',
                          title: 'Contact information',
                          items: [
                            SellerProfileInfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Phone number',
                              value: phone,
                            ),
                            SellerProfileInfoItem(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: address,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.defaultPadding,
                          14,
                          AppConstants.defaultPadding,
                          0,
                        ),
                        child: SellerProfileSections(
                          isLoggingOut: _isLoggingOut,
                          onEditProfile: _editProfile,
                          onChangePassword: _showChangePassword,
                          onLogout: _confirmLogout,
                          sellerSince: sellerSince,
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

  // =============================================================
  // DATE
  // =============================================================
}

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
