import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/tabs/admin_analytics_home_tab.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/views/login_screen.dart';
import '../../../core/widgets/custom_bottom_navbar.dart';

import 'tabs/admin_menu_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_settings_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const AdminDashboardScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Set index to 1 so AdminMenuTab is displayed by default
  int _selectedIndex = 1;
  final AuthService _authService = AuthService();

  void _handleLogout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          currentThemeMode: widget.currentThemeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
    );
  }

  static const List<CustomNavBarItem> _navItems = [
    CustomNavBarItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
      label: 'Home',
    ),
    CustomNavBarItem(
      icon: Icons.local_drink_outlined,
      selectedIcon: Icons.local_drink_rounded,
      label: 'Menu',
    ),
    CustomNavBarItem(
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt_rounded,
      label: 'Users',
    ),
    CustomNavBarItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Widget> pages = [
      const AdminAnalyticsHomeTab(),
      const AdminMenuTab(),
      const AdminUsersTab(),
      AdminSettingsTab(
        onLogout: _handleLogout,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems,
      ),
    );
  }
}