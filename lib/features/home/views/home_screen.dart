import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/home/controllers/home_controller.dart';
import 'package:my_business/features/home/widgets/product_banner_card.dart';
import 'package:my_business/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(
      HomeController(),
    ); // Controller instance create korun
    // ScaffoldState control korar jonno ekta GlobalKey (Optional but safe)
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey, // Key-ti ekhane assign korte hobe
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Seller Dashboard'),
        // Menu icon-e click korle drawer open hobe
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Drawer open korar command
          },
        ),
      ),

      // Drawer-ti ekhane thakbe
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

            Expanded(
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return const ProductBannerCard(
                    productCode: 'BLCH1',
                    quantity: 10,
                    price: 300,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: SizedBox(
                height: 55,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.openAddProductForm();
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text(
                    'Add New Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
