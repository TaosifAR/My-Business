import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerDashboardController extends GetxController {
  // Input Controllers
  final productCodeController = TextEditingController();
  final quantityController = TextEditingController();
  final buyingPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();

  // Observable Variables
  var sizeQuantities = <String, int>{}.obs;
  var products = <Map<String, dynamic>>[].obs;
  var isEditMode = false.obs; 

  // --- UI Form Management ---
  void openAddProductForm() {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add New Product",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 15),

              // Product Code (Manual Input Only)
              _buildInputField("Product Code", "Enter code", productCodeController, TextInputType.text),

              const SizedBox(height: 15),

              // Size and Individual Stock
              _buildLabel("Available Sizes & Stock"),
              Obx(() => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["S", "M", "L", "XL", "XXL"].map((size) {
                  bool hasStock = sizeQuantities.containsKey(size);
                  return ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(size, style: TextStyle(
                          color: hasStock ? Colors.white : Colors.black, 
                          fontWeight: FontWeight.bold
                        )),
                        if (hasStock)
                          Text("${sizeQuantities[size]} pcs", 
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                    selected: hasStock,
                    selectedColor: const Color(0xFF10B981),
                    onSelected: (val) => showQuantityInputDialog(size),
                  );
                }).toList(),
              )),

              const SizedBox(height: 15),

              // Qty and Buying Price Row
              Row(
                children: [
                  Expanded(child: _buildInputField("Total Qty", "Auto", quantityController, TextInputType.number, enabled: false)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField("Buying Price", "0.0", buyingPriceController, TextInputType.number)),
                ],
              ),

              const SizedBox(height: 15),

              // Selling Price
              _buildInputField("Selling Price", "0.0", sellingPriceController, TextInputType.number),

              const SizedBox(height: 25),

              // Save Action
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Save Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dialogs & Calculations ---
  void showQuantityInputDialog(String size) {
    final qtyInputController = TextEditingController(
        text: sizeQuantities.containsKey(size) ? sizeQuantities[size].toString() : "");

    Get.defaultDialog(
      title: "Stock for Size $size",
      content: TextField(
        controller: qtyInputController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: "Enter quantity", filled: true, fillColor: Colors.grey.shade100),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (qtyInputController.text.isNotEmpty) {
            sizeQuantities[size] = int.parse(qtyInputController.text);
          } else {
            sizeQuantities.remove(size);
          }
          _calculateTotalQuantity();
          Get.back();
        },
        child: const Text("Set"),
      ),
    );
  }

  void _calculateTotalQuantity() {
    int total = 0;
    sizeQuantities.forEach((key, value) => total += value);
    quantityController.text = total.toString();
  }

  void _saveData() {
    if (productCodeController.text.isEmpty || sellingPriceController.text.isEmpty) {
      Get.snackbar("Error", "Required fields are empty", 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Add to Local List
    products.add({
      'productCode': productCodeController.text,
      'quantity': quantityController.text,
      'sellingPrice': sellingPriceController.text,
      'buyingPrice': buyingPriceController.text,
      'sizes': Map.from(sizeQuantities),
    });

    // Clear Fields for next entry
    _clearForm();

    Get.back(); // Close bottom sheet
    Get.snackbar("Success", "Product added to Inventory", 
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _clearForm() {
    productCodeController.clear();
    quantityController.clear();
    buyingPriceController.clear();
    sellingPriceController.clear();
    sizeQuantities.clear();
  }
  // Product Update Function (Optional)
void updateProduct(int index) {
  if (productCodeController.text.isEmpty || sellingPriceController.text.isEmpty) {
    Get.snackbar("Error", "Fields cannot be empty");
    return;
  }

  products[index] = {
    'productCode': productCodeController.text,
    'quantity': quantityController.text,
    'sellingPrice': sellingPriceController.text,
    'buyingPrice': buyingPriceController.text,
    'sizes': Map.from(sizeQuantities),
  };

  products.refresh();
  Get.back(); 
  Get.snackbar("Success", "Product updated successfully");
}

  // --- Helper Widgets ---
  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)));
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, TextInputType type, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: type,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? const Color(0xFFF8FAFC) : Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  @override
  void onClose() {
    productCodeController.dispose();
    quantityController.dispose();
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    super.onClose();
  }
}