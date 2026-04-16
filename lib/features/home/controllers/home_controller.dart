import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Input fields er data dhorar jonno controllers
  final productCodeController = TextEditingController();
  final quantityController = TextEditingController();
  final buyingPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  
  // Selected size track korar jonno (Shoes size)
  var selectedSize = "".obs;

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
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 15),

              // Product Code Field
              _buildLabel("Product Code"),
              TextField(
                controller: productCodeController,
                decoration: InputDecoration(
                  hintText: "Enter code or Scan",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF10B981)),
                    onPressed: () => print("Camera Logic Here"),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Quantity & Buying Price Row
              Row(
                children: [
                  Expanded(child: _buildInputField("Quantity", "0", quantityController, TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField("Buying Price", "\$0.0", buyingPriceController, TextInputType.number)),
                ],
              ),

              const SizedBox(height: 15),
              _buildInputField("Selling Price", "\$0.0", sellingPriceController, TextInputType.number),

              const SizedBox(height: 15),

              // Shoes Size Selection
              _buildLabel("Available Sizes (Shoes)"),
              Obx(() => Wrap(
                spacing: 8,
                children: ["38", "39", "40", "41", "42", "43"].map((size) {
                  return ChoiceChip(
                    label: Text(size),
                    selected: selectedSize.value == size,
                    onSelected: (val) => selectedSize.value = size,
                    selectedColor: const Color(0xFF10B981),
                    labelStyle: TextStyle(
                      color: selectedSize.value == size ? Colors.white : Colors.black,
                      fontSize: 12
                    ),
                  );
                }).toList(),
              )),

              const SizedBox(height: 25),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Ekhane save logic hobe
                    _saveData();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A)),
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

  // Helper function for Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  // Helper widget for Input Fields
  Widget _buildInputField(String label, String hint, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _saveData() {
    // Ekhane check korben data thik ache kina
    print("Saving: ${productCodeController.text}");
    Get.back();
    Get.snackbar("Success", "Product added successfully",
        backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
  }

  @override
  void onClose() {
    // Memory clean up
    productCodeController.dispose();
    quantityController.dispose();
    buyingPriceController.dispose();
    sellingPriceController.dispose();
    super.onClose();
  }
}



