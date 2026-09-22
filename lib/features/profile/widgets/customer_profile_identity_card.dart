import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class CustomerProfileIdentityCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onEditAvatar;

  const CustomerProfileIdentityCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: hasAvatar
                          ? Image.network(
                              avatarUrl!,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return _avatarFallback();
                              },
                            )
                          : _avatarFallback(),
                    ),
                  ),

                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onEditAvatar,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'CUSTOMER',
                            style: TextStyle(
                              fontSize: 6.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.9,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name.trim().isEmpty ? 'Customer' : name.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.alternate_email_rounded,
                          size: 11,
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.65,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Change profile photo',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEditAvatar,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.22)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: _SummaryItem(
                  icon: Icons.person_outline_rounded,
                  label: 'ACCOUNT',
                  value: 'Customer Account',
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.border.withValues(alpha: 0.24),
              ),
              const Expanded(
                child: _SummaryItem(
                  icon: Icons.verified_user_outlined,
                  label: 'STATUS',
                  value: 'Active',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_rounded,
        size: 40,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    color: AppColors.textSecondary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
