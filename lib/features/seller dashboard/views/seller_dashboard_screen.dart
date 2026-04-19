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
    final SellerDashboardController controller = Get.find<SellerDashboardController>();
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Dashboard",
        showBackButton: true,
        scaffoldKey: _scaffoldKey,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  " Product Inventory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Obx use kora holo jate list update holei ekhane dekhay
            Expanded(
              child: Obx(() {
                if (controller.products.isEmpty) {
                  return const Center(child: Text("No products added yet."));
                }
                return ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return InkWell(
                      onTap: () => Get.to(() => ProductInfoScreen(index: index)),
                      child: ProductBannerCard(
                        productCode: product['productCode'],
                        quantity: int.parse(product['quantity']),
                        price: double.parse(product['sellingPrice']),
                      ),
                    );
                  },
                );
              }),
            ),

            // Add Product Button
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.openAddProductForm(),
                  icon: const Icon(Icons.add_a_photo, color: Colors.white),
                  label: const Text('Add New Product', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
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