import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/views/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  // Navigation targets for the Admin Portal
  final List<Widget> _adminPages = const [
    AdminOverviewTab(),
    AdminUsersTab(),
    AdminProductsTab(),
  ];

  void _handleLogout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Legit Smoothie - Admin Portal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          // Professional Side Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey.shade100,
            selectedIconTheme: const IconThemeData(color: Colors.green),
            selectedLabelTextStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text('Menu / Products'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            child: _adminPages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// --- Tab 1: Overview Dashboard ---
class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Admin Austin! 🥤',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is a quick snapshot of The Legit Smoothie operations.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Total Orders', '0', Icons.shopping_bag, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Active Sellers', '0', Icons.store, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('Registered Customers', '0', Icons.person, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Tab 2: User Management Placeholder ---
class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Management Portal (Admins, Sellers, Customers)',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

// --- Tab 3: Products Management Placeholder ---
class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Product Inventory Management (Smoothies, Milktea, Siomai, Pancit Canton)',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}