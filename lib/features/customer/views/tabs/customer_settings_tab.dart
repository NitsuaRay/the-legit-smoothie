import 'package:flutter/material.dart';

class CustomerSettingsTab extends StatelessWidget {
  final VoidCallback onLogout;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const CustomerSettingsTab({
    super.key,
    required this.onLogout,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Title
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Profile Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[900]?.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valued Customer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'customer@legitsmoothie.com',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // Edit Profile Action
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Account Section
          _buildSectionHeader(context, 'Account Settings'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: 'Order History',
                subtitle: 'View your previous smoothie orders',
                onTap: () {
                  // Navigate to order history
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.location_on_outlined,
                title: 'Delivery Addresses',
                subtitle: 'Manage saved delivery locations',
                onTap: () {
                  // Navigate to address management
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                subtitle: 'Manage saved cards & GCash',
                onTap: () {
                  // Navigate to payment options
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. Preferences & Appearance
          _buildSectionHeader(context, 'App Preferences'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              // Theme Toggle Selector
              ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: const Text(
                  'Theme Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  currentThemeMode == ThemeMode.system
                      ? 'System Default'
                      : currentThemeMode == ThemeMode.dark
                          ? 'Dark Mode'
                          : 'Light Mode',
                ),
                trailing: DropdownButton<ThemeMode>(
                  value: currentThemeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      onThemeModeChanged(newMode);
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Promotional offers & order updates',
                onTap: () {
                  // Notification settings
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 5. Support & Legal
          _buildSectionHeader(context, 'Support & Legal'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.help_outline_rounded,
                title: 'Help Center & Support',
                subtitle: 'FAQs and direct contact',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 6. Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[700],
          ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]?.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your account?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}