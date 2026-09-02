import 'package:flutter/material.dart';
import 'package:the_legit_smoothie/features/cart/screens/cart_screen.dart';
import 'package:the_legit_smoothie/features/cart/services/cart_service.dart';
import 'package:the_legit_smoothie/features/catalog/screens/home_screen.dart';
import 'package:the_legit_smoothie/features/orders/screens/order_history_screen.dart';
import 'package:the_legit_smoothie/features/profile/screens/profile_screen.dart';
import 'package:the_legit_smoothie/features/promotions/screens/promotions_screen.dart';
import '../../../core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {}); // Rebuild to update cart badge count dynamically
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    PromotionsScreen(),
    CartScreen(),
    OrderHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'Deals',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('${_cartService.itemCount}'),
              isLabelVisible: _cartService.itemCount > 0,
              backgroundColor: AppColors.secondaryDark,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            activeIcon: Badge(
              label: Text('${_cartService.itemCount}'),
              isLabelVisible: _cartService.itemCount > 0,
              backgroundColor: AppColors.secondaryDark,
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
