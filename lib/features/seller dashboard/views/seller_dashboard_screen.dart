import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';
import 'package:my_business/features/seller%20dashboard/views/product_info.dart';
import 'package:my_business/features/seller%20dashboard/widgets/product_banner_card.dart';
import 'package:my_business/widgets/app_drawer.dart';
import 'package:my_business/widgets/custom_appbar.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.find ekhane ekbar kora-i bhalo
    final controller = Get.find<SellerDashboardController>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Dashboard",
        showBackButton: true,
        scaffoldKey: scaffoldKey,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Inventory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.products.isEmpty) {
                  return const Center(child: Text("No products added yet."));
                }
                return ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    
                    // FIX: Key names update kora hoyeche (Firebase sync-er sathe mil rekhe)
                    return InkWell(
                      onTap: () => Get.to(() => ProductInfoScreen(index: index)),
                      child: ProductBannerCard(
                        productCode: product['productCode'] ?? "N/A",
                        // Firebase-e amra 'totalQuantity' name save korechi
                        quantity: product['totalQuantity'] ?? 0, 
                        price: (product['sellingPrice'] is int) 
                                ? (product['sellingPrice'] as int).toDouble() 
                                : (product['sellingPrice'] ?? 0.0),
                      ),
                    );
                  },
                );
              }),
            ),

            // Add Product Button
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Direct call without Get.find repeat
                    controller.openAddProductForm();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add New Product', 
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}