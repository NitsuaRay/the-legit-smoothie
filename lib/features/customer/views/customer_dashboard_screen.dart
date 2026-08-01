import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/customer/views/tabs/customer_cart_tab.dart';
import 'package:the_legit_smoothie/features/customer/views/tabs/customer_menu_tab.dart';
import 'package:the_legit_smoothie/features/customer/views/tabs/customer_orders_tab.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/views/login_screen.dart';
import '../../../core/widgets/custom_bottom_navbar.dart';

// Import your customer tabs here
import 'tabs/customer_home_tab.dart';
// import 'tabs/customer_orders_tab.dart'; // Add other tabs as you create them
import 'tabs/customer_settings_tab.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const CustomerDashboardScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  // Starts at index 0 (Customer Home / Menu)
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

    // Theme-based background image matching Admin and Seller
    final String backgroundImage = isDark
        ? 'assets/bgBrown.png'
        : 'assets/bgWhite.png';

    final List<Widget> pages = [
      const CustomerHomeTab(), // Index 0: Home
      const CustomerMenuTab(), // Index 1: Menu
      const CustomerCartTab(), // Index 2: Cart
      const CustomerOrderTab(), // Index 3: Orders
      CustomerSettingsTab(
        // Index 4: Settings
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
          child: IndexedStack(index: _selectedIndex, children: pages),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        role: UserRole
            .customer, // Make sure UserRole.customer exists in your enum
      ),
    );
  }
}
