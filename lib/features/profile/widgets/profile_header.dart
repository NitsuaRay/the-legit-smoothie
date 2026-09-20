import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

class ProfileHeader extends StatefulWidget {
  final String fullName;
  final String email;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _imagePicker = ImagePicker();

  String? _avatarUrl;

  bool _isLoadingAvatar = true;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  // ============================================================
  // LOAD CURRENT AVATAR
  // ============================================================

  Future<void> _loadAvatar() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingAvatar = false;
        });
      }
      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _avatarUrl = data?['avatar_url'] as String?;
        _isLoadingAvatar = false;
      });
    } catch (e) {
      debugPrint('Error loading avatar: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  // ============================================================
  // SHOW AVATAR SOURCE OPTIONS
  // ============================================================

  Future<void> _showAvatarOptions() async {
    if (_isUploadingAvatar) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Choose how you want to update your photo',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _AvatarSourceButton(
                        icon: Icons.camera_alt_rounded,
                        title: 'Camera',
                        subtitle: 'Take photo',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);

                          _pickAndUploadAvatar(
                            ImageSource.camera,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _AvatarSourceButton(
                        icon: Icons.photo_library_rounded,
                        title: 'Gallery',
                        subtitle: 'Choose photo',
                        onTap: () {
                          Navigator.pop(bottomSheetContext);

                          _pickAndUploadAvatar(
                            ImageSource.gallery,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                if (_avatarUrl != null && _avatarUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(bottomSheetContext);
                        _removeAvatar();
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                      ),
                      label: const Text('Remove current photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PICK + UPLOAD AVATAR
  // ============================================================

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedImage == null) return;

      final user = supabase.auth.currentUser;

      if (user == null) {
        _showErrorMessage('You are not signed in.');
        return;
      }

      if (mounted) {
        setState(() {
          _isUploadingAvatar = true;
        });
      }

      final file = File(pickedImage.path);

      // Get file extension.
      final extension = pickedImage.path
          .split('.')
          .last
          .toLowerCase();

      final safeExtension = [
        'jpg',
        'jpeg',
        'png',
        'webp',
      ].contains(extension)
          ? extension
          : 'jpg';

      // Timestamp prevents stale cached avatars.
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final storagePath =
          '${user.id}/avatar_$timestamp.$safeExtension';

      // Upload image.
      await supabase.storage.from('avatars').upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _getContentType(safeExtension),
            ),
          );

      // Get public URL.
      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(storagePath);

      final previousAvatarUrl = _avatarUrl;

      // Update profiles table.
      await supabase.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (!mounted) return;

      setState(() {
        _avatarUrl = publicUrl;
      });

      _showSuccessMessage('Profile photo updated');

      // Optional cleanup of previous avatar.
      if (previousAvatarUrl != null &&
          previousAvatarUrl.isNotEmpty) {
        await _deleteOldAvatar(previousAvatarUrl);
      }
    } catch (e) {
      debugPrint('Avatar upload error: $e');

      if (!mounted) return;

      _showErrorMessage(
        'Failed to update profile photo.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  // ============================================================
  // REMOVE AVATAR
  // ============================================================

  Future<void> _removeAvatar() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final currentAvatar = _avatarUrl;

    try {
      setState(() {
        _isUploadingAvatar = true;
      });

      await supabase.from('profiles').update({
        'avatar_url': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (currentAvatar != null && currentAvatar.isNotEmpty) {
        await _deleteOldAvatar(currentAvatar);
      }

      if (!mounted) return;

      setState(() {
        _avatarUrl = null;
      });

      _showSuccessMessage('Profile photo removed');
    } catch (e) {
      debugPrint('Remove avatar error: $e');

      if (!mounted) return;

      _showErrorMessage(
        'Failed to remove profile photo.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE OLD FILE FROM STORAGE
  // ============================================================

  Future<void> _deleteOldAvatar(String avatarUrl) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final uri = Uri.parse(avatarUrl);

      final fileName = uri.pathSegments.last;

      final oldStoragePath = '${user.id}/$fileName';

      await supabase.storage.from('avatars').remove([
        oldStoragePath,
      ]);
    } catch (e) {
      // Do not fail the whole avatar update just because
      // old-file cleanup failed.
      debugPrint('Old avatar cleanup failed: $e');
    }
  }

  // ============================================================
  // CONTENT TYPE
  // ============================================================

  String _getContentType(String extension) {
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

  // ============================================================
  // SNACKBARS
  // ============================================================

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final displayName = widget.fullName.trim().isNotEmpty
        ? widget.fullName.trim()
        : 'User';

    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    final hasAvatar =
        _avatarUrl != null && _avatarUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ====================================================
          // AVATAR
          // ====================================================

          GestureDetector(
            onTap: _isUploadingAvatar
                ? null
                : _showAvatarOptions,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Outer decorative ring
                Container(
                  width: 104,
                  height: 104,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.45),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.18,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryAccent
                          .withValues(alpha: 0.18),

                      backgroundImage:
                          hasAvatar && !_isLoadingAvatar
                              ? NetworkImage(_avatarUrl!)
                              : null,

                      child: _buildAvatarContent(
                        initial,
                        hasAvatar,
                      ),
                    ),
                  ),
                ),

                // =================================================
                // EDIT BUTTON
                // =================================================

                Positioned(
                  bottom: 0,
                  right: -2,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isUploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ====================================================
          // NAME
          // ====================================================

          Text(
            displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (widget.email.isNotEmpty) ...[
            const SizedBox(height: 5),

            Text(
              widget.email,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary.withValues(
                  alpha: 0.85,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 14),

          // ====================================================
          // CUSTOMER BADGE
          // ====================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.primary.withValues(
                  alpha: 0.14,
                ),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: AppColors.primary,
                ),

                SizedBox(width: 6),

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

          const SizedBox(height: 12),

          Text(
            'Tap your photo to update',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary.withValues(
                alpha: 0.65,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVATAR CONTENT
  // ============================================================

  Widget? _buildAvatarContent(
    String initial,
    bool hasAvatar,
  ) {
    if (_isLoadingAvatar) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      );
    }

    if (hasAvatar) {
      return null;
    }

    return Text(
      initial,
      style: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }
}

// ============================================================
// AVATAR SOURCE BUTTON
// ============================================================

class _AvatarSourceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AvatarSourceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.06,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}