import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';

class ProductInfoScreen extends StatelessWidget {
  final int index; // Index of the product to be edited
  final SellerDashboardController controller = Get.find();

  ProductInfoScreen({super.key, required this.index}) {
    // Edit mode remains OFF when the screen opens
    controller.isEditMode.value = false;

    var product = controller.products[index];
    controller.productCodeController.text = product['productCode'];
    controller.buyingPriceController.text = product['buyingPrice'];
    controller.sellingPriceController.text = product['sellingPrice'];
    controller.quantityController.text = product['quantity'];
    controller.sizeQuantities.value = Map<String, int>.from(product['sizes']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Info", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button to toggle modes
          Obx(() => IconButton(
            icon: Icon(
              controller.isEditMode.value ? Icons.lock_open : Icons.edit, 
              color: Colors.blue
            ),
            onPressed: () => controller.isEditMode.toggle(),
          ))
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The 'enabled' property works based on isEditMode
            _buildInfoField(
              "Product Code", 
              controller.productCodeController, 
              enabled: controller.isEditMode.value
            ),
            const SizedBox(height: 15),
            
            const Text("Available Sizes & Stock", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ["S", "M", "L", "XL", "XXL"].map((size) {
                bool hasStock = controller.sizeQuantities.containsKey(size);
                return ActionChip(
                  // pressElevation set to 0 to prevent extra shadows or color changes on click
                  pressElevation: 0, 
                  label: Text(
                    "$size ${hasStock ? '(${controller.sizeQuantities[size]} pcs)' : ''}",
                    style: TextStyle(color: hasStock ? Colors.white : Colors.black),
                  ),
                  // Color remains fixed; it won't change even if Edit Mode is ON
                  backgroundColor: hasStock ? const Color(0xFF10B981) : Colors.grey.shade200,
                  
                  onPressed: controller.isEditMode.value 
                      ? () => controller.showQuantityInputDialog(size) 
                      : () {}, // Providing an empty function instead of null keeps the default color
                );
              }).toList(),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                // Total Qty is always locked because it is auto-calculated
                Expanded(child: _buildInfoField("Total Qty", controller.quantityController, enabled: false)), 
                const SizedBox(width: 15),
                Expanded(child: _buildInfoField(
                  "Buying Price", 
                  controller.buyingPriceController, 
                  enabled: controller.isEditMode.value
                )),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoField(
              "Selling Price", 
              controller.sellingPriceController, 
              enabled: controller.isEditMode.value
            ),
            
            const SizedBox(height: 40),
            
            // The button is only visible or functional when in Edit Mode
            if (controller.isEditMode.value)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateProduct(index);
                    controller.isEditMode.value = false; // Lock the fields again after updating
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Update Product Info", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
          ],
        )),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController ctr, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        TextField(
          controller: ctr,
          enabled: enabled,
          style: TextStyle(color: enabled ? Colors.black : Colors.grey.shade600),
          decoration: InputDecoration(
            // Bottom border is hidden when the field is locked (disabled)
            border: enabled ? const UnderlineInputBorder() : InputBorder.none, 
          ),
        ),
      ],
    );
  }
}