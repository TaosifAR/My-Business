import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/seller%20dashboard/bindings/seller_dashboard_bindings.dart';
import 'package:my_business/features/seller%20dashboard/views/seller_dashboard_screen.dart';
import 'package:my_business/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('My Business'), centerTitle: true),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuTile(
            title: "Dashboard",
            subtitle: "Inventory, Stats & Overview",
            icon: Icons.dashboard_customize_rounded,
            color: const Color(0xFF0F172A), // Navy
            onTap: () {
              Get.to(
                () => const SellerDashboardScreen(),
                binding: SellerDashboardBindings(),
              );
              print("Opening Dashboard...");
            },
          ),
          _buildMenuTile(
            title: "Product Sell",
            subtitle: "Generate New Invoice",
            icon: Icons.point_of_sale_rounded,
            color: const Color(0xFF10B981), // Emerald Green
            onTap: () => print("Sell Page"),
          ),
          _buildMenuTile(
            title: "Product Return",
            subtitle: "Manage Customer Returns",
            icon: Icons.assignment_return_rounded,
            color: Colors.orangeAccent,
            onTap: () => print("Return Page"),
          ),
          _buildMenuTile(
            title: "Settings",
            subtitle: "App & Account Setup",
            icon: Icons.settings_suggest_rounded,
            color: Colors.blueGrey,
            onTap: () => print("Settings Page"),
          ),
        ],
      ),
    );
  }

  // Smart List Tile Helper
  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
