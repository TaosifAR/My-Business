import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';

class ProductInfoScreen extends StatelessWidget {
  final int index;
  final SellerDashboardController controller = Get.find();

  ProductInfoScreen({super.key, required this.index}) {
    _initializeData();
  }

  void _initializeData() {
    // Reset state
    controller.isEditMode.value = false;

    // Fetch product data safely
    if (index >= 0 && index < controller.products.length) {
      var product = controller.products[index];

      // Initialize Text Controllers
      controller.productCodeController.text = product['productCode']?.toString() ?? "";
      controller.buyingPriceController.text = product['buyingPrice']?.toString() ?? "0.0";
      controller.sellingPriceController.text = product['sellingPrice']?.toString() ?? "0.0";
      controller.quantityController.text = product['totalQuantity']?.toString() ?? "0";

      // Initialize Size Map safely
      if (product['sizes'] != null) {
        Map<String, int> convertedSizes = {};
        (product['sizes'] as Map).forEach((key, value) {
          convertedSizes[key.toString()] = int.tryParse(value.toString()) ?? 0;
        });
        controller.sizeQuantities.assignAll(convertedSizes);
      } else {
        controller.sizeQuantities.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get docId from reactive list
    var product = controller.products[index];
    String docId = product['docId'] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isEditMode.value ? Icons.lock_open : Icons.edit,
              color: controller.isEditMode.value ? Colors.green : Colors.blue,
            ),
            onPressed: () => controller.isEditMode.toggle(),
          )),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoField(
                "Product Code",
                controller.productCodeController,
                enabled: controller.isEditMode.value,
              ),
              const SizedBox(height: 25),

              const Text(
                "STOCK BY SIZE",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
              ),
              const SizedBox(height: 12),
              
              // Reactive Size Chips
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["S", "M", "L", "XL", "XXL"].map((size) {
                  int quantity = controller.sizeQuantities[size] ?? 0;
                  bool hasStock = quantity > 0;
                  
                  return InkWell(
                    onTap: controller.isEditMode.value 
                        ? () => controller.showQuantityInputDialog(size) 
                        : null,
                    borderRadius: BorderRadius.circular(30),
                    child: Chip(
                      label: Text(
                        "$size ${quantity > 0 ? '($quantity)' : ''}",
                        style: TextStyle(
                          color: hasStock ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: hasStock ? const Color(0xFF10B981) : Colors.grey.shade100,
                      side: BorderSide(color: hasStock ? Colors.transparent : Colors.grey.shade300),
                    ),
                  );
                }).toList(),
              )),
              
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      "Total Stock (Auto)",
                      controller.quantityController,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInfoField(
                      "Buying Price (৳)",
                      controller.buyingPriceController,
                      enabled: controller.isEditMode.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildInfoField(
                "Selling Price (৳)",
                controller.sellingPriceController,
                enabled: controller.isEditMode.value,
              ),

              const SizedBox(height: 40),

              // Save Button
              Obx(() => controller.isEditMode.value 
                ? SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        await controller.updateProduct(docId);
                        controller.isEditMode.value = false;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoField(String label, TextEditingController ctr, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctr,
          enabled: enabled,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
          ),
        ),
      ],
    );
  }
}