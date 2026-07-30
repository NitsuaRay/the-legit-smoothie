import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/seller/views/tabs/seller_analytics_tab.dart.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/views/login_screen.dart';
import '../../../core/widgets/custom_bottom_navbar.dart';

import 'tabs/seller_menu_tab.dart';
import 'tabs/seller_sales_tab.dart';
import 'tabs/seller_orders_tab.dart';
import 'tabs/seller_settings_tab.dart';

class SellerDashboardScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SellerDashboardScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background image selected based on the active theme
    final String backgroundImage =
        isDark ? 'assets/bgBrown.png' : 'assets/bgWhite.png';

    // List of pages mapped exactly to the 5 tabs in CustomBottomNavBar
    final List<Widget> pages = [
      const SellerAnalyticsTab(),
      const SellerMenuTab(),
      const SellerSalesTab(),
      const SellerOrdersTab(),
      SellerSettingsTab(
        onLogout: _handleLogout,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        role: UserRole.seller,
      ),
    );
  }
}