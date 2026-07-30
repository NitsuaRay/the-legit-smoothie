import 'package:flutter/material.dart';

class AdminMenuTab extends StatelessWidget {
  const AdminMenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Smoothie Menu & Inventory Management',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }
}