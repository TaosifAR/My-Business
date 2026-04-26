import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/auth/controllers/auth_controller.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login');

      Get.snackbar(
        "Logout",
        "Successfully logged out",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
      );
    } catch (e) {
      Get.snackbar("Error", "Logout failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header Section
          Obx(() => UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A), 
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 45, color: Color(0xFF0F172A)),
                  ),
                ),
                accountName: Text(
                  authController.userName.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(
                  authController.userEmail.value,
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              )),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
               
                

                // NEW: About Developer Option
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: "About Developer",
                  onTap: () => _showDeveloperInfo(context),
                ),

                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  label: "Logout",
                  color: Colors.redAccent,
                  onTap: () {
                    Get.defaultDialog(
                      title: "Logout",
                      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
                      middleText: "Are you sure you want to logout?",
                      textConfirm: "Yes, Logout",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      onConfirm: () {
                        Get.back();
                        _handleLogout();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "v1.0.2",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // Developer Info Dialog
  void _showDeveloperInfo(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xFF10B981),
              child: Icon(Icons.code, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 15),
            const Text(
              "Taosif Ahmad Rasif",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const Text(
              "B.Sc in CSE from IIUC",
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const Divider(height: 30),
            _buildContactRow(Icons.email_outlined, "taosifahmed015@gmail.com"),
            const SizedBox(height: 12),
            _buildContactRow(Icons.phone_android_outlined, "+8801985546409"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF10B981)),
        const SizedBox(width: 10),
        Text(data, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: color ?? const Color(0xFF0F172A)),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color ?? const Color(0xFF0F172A),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}