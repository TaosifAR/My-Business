import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header: Ekhane Seller-er info thakbe
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF10B981)),
            ),
            accountName: const Text("Seller Name"),
            accountEmail: const Text("seller@email.com"),
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Dashboard"),
            onTap: () => Get.back(), // Drawer bondho korbe
          ),
          
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Sales History"),
            onTap: () {
              // History page-e jaoar logic
            },
          ),
           ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("My Profits"),
            onTap: () {
              // History page-e jaoar logic
            },
          ),

          const Divider(), // Ekta line tanbe

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Firebase Logout logic ekhane hobe
              Get.snackbar("Logout", "Successfully logged out");
            },
          ),
        ],
      ),
    );
  }
}