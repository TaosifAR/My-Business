import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';

class ProductInfoScreen extends StatelessWidget {
  final int index;
  final SellerDashboardController controller = Get.find();

  ProductInfoScreen({super.key, required this.index}) {
    // Initializing state
    controller.isEditMode.value = false;

    // Fetch the specific product from the list
    var product = controller.products[index];

    // Filling controllers with saved data
    controller.productCodeController.text = product['productCode']?.toString() ?? "";
    controller.buyingPriceController.text = product['buyingPrice']?.toString() ?? "0.0";
    controller.sellingPriceController.text = product['sellingPrice']?.toString() ?? "0.0";
    controller.quantityController.text = product['totalQuantity']?.toString() ?? "0";

    if (product['sizes'] != null) {
      controller.sizeQuantities.assignAll(
        Map<String, int>.from(product['sizes']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Getting the product again inside build to get the docId
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
                "Stock by Size",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 12),
              
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["S", "M", "L", "XL", "XXL"].map((size) {
                  bool hasStock = controller.sizeQuantities.containsKey(size);
                  return ActionChip(
                    label: Text(
                      "$size ${hasStock ? '(${controller.sizeQuantities[size]})' : ''}",
                      style: TextStyle(
                        color: hasStock ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: hasStock ? const Color(0xFF10B981) : Colors.grey.shade100,
                    onPressed: controller.isEditMode.value
                        ? () => controller.showQuantityInputDialog(size)
                        : null,
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

              // Save Changes button shows only when in Edit Mode
              Obx(() => controller.isEditMode.value 
                ? SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Using docId instead of index for safer update
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
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11),
        ),
        TextField(
          controller: ctr,
          enabled: enabled,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: enabled ? const UnderlineInputBorder() : InputBorder.none,
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0F172A), width: 2)),
          ),
        ),
      ],
    );
  }
}