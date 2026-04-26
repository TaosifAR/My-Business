import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/business%20oveview/views/business_overview_screen.dart';
import 'package:my_business/routes/app_routes.dart';
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
          // 1. Order Entry (The starting point for everything)
         

          // 2. Dashboard
          _buildMenuTile(
            title: "Dashboard",
            subtitle: "Inventory, Stats & Overview",
            icon: Icons.dashboard_customize_rounded,
            color: const Color(0xFF0F172A), // Navy
            onTap: () {
              Get.offAllNamed(AppRoutes.dashboard);
            },
          ),
           _buildMenuTile(
            title: "Order Entry",
            subtitle: "Create New Order & Shipment",
            icon: Icons.add_shopping_cart_rounded,
            color: const Color(0xFF6366F1), // Indigo/Violet
            onTap: () => Get.toNamed("/orderentry"), 
          ),

          // 3. Sales History (Renamed from Product Sell)
          _buildMenuTile(
            title: "Sales History",
            subtitle: "View Confirmed Sales",
            icon: Icons.point_of_sale_rounded,
            color: const Color(0xFF10B981), // Green
            onTap: () => Get.toNamed("/productsell"), 
          ),

          // 4. Returns History (Renamed from Product Return)
          _buildMenuTile(
            title: "Returns History",
            subtitle: "Track Customer Returns",
            icon: Icons.assignment_return_rounded,
            color: Colors.orangeAccent,
            onTap: () => Get.toNamed("/productreturn"),
          ),

         // 5. Business Overview
_buildMenuTile(
  title: "Business Overview",
  subtitle: "Investment, Profit & Loss Analytics",
  icon: Icons.pie_chart_rounded, // অথবা Icons.bar_chart_rounded ব্যবহার করতে পারেন
  color: Colors.indigo, // প্রফেশনাল রিপোর্টের জন্য ইন্ডিগো বা ব্লু কালার ভালো দেখায়
  onTap: () => Get.toNamed("/businessoverview"), // আপনার তৈরি করা স্ক্রিনটির নাম দিন
),
        ],
      ),
    );
  }

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