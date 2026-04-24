import 'package:firebase_auth/firebase_auth.dart'; // 1. Firebase Auth import koren
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/auth/controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {

  const AppDrawer({super.key});
  

  // Logout Function
  void _handleLogout() async {
    try {
      // 2. Firebase theke sign out kora
      await FirebaseAuth.instance.signOut();

      // 3. Login screen-e niye jaoa ebong ager shob routes delete kora
      // Get.offAllNamed use korle user back button chepe ar dashboard-e firte parbe na
      Get.offAllNamed('/login');

      Get.snackbar(
        "Logout",
        "Successfully logged out",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
      final authController = Get.find<AuthController>();
    return Drawer(
      child: Column(
        children: [
       Obx(() => UserAccountsDrawerHeader(
  decoration: const BoxDecoration(color: Color(0xFF10B981)),
  currentAccountPicture: const CircleAvatar(
    backgroundColor: Colors.white,
    child: Icon(Icons.person, size: 40, color: Color(0xFF10B981)),
  ),
  accountName: Text(authController.userName.value), // Dynamic Name
  accountEmail: Text(authController.userEmail.value), // Dynamic Email
)),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Dashboard"),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Sales History"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text("My Profits"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              // 4. Logout confirm korar jonno ekta dialog dekhate paren (Optional but Good UX)
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  Get.back(); // Dialog bondho korbe
                  _handleLogout(); // Logout logic call korbe
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
