import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Input Controllers
  final productCodeController = TextEditingController();
  final quantityController = TextEditingController();
  final buyingPriceController = TextEditingController();
  final sellingPriceController = TextEditingController();

  // Observable Variables
  var sizeQuantities = <String, int>{}.obs;
  var products = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isEditMode = false.obs;
  var currentEditingDocId = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Start listening to data as soon as the controller initializes
    listenToProducts();
  }

  // --- Real-time Data Sync ---
  // Listens to products belonging only to the logged-in user
  void listenToProducts() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestore
        .collection('products')
        .where('sellerId', isEqualTo: uid) // Filter data by the current user's UID
        .snapshots()
        .listen((snapshot) {
      products.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  // --- UI Form Management ---
  void openAddProductForm() {
    _clearForm();
    isEditMode.value = false; // Reset to add mode
    
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
              _buildInputField("Product Code", "Enter code", productCodeController, TextInputType.text),
              const SizedBox(height: 15),
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
              Row(
                children: [
                  Expanded(child: _buildInputField("Total Qty", "Auto", quantityController, TextInputType.number, enabled: false)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInputField("Buying Price", "0.0", buyingPriceController, TextInputType.number)),
                ],
              ),
              const SizedBox(height: 15),
              _buildInputField("Selling Price", "0.0", sellingPriceController, TextInputType.number),
              const SizedBox(height: 25),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : _saveDataToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Firebase Operations ---
  Future<void> _saveDataToFirebase() async {
    if (productCodeController.text.isEmpty || sellingPriceController.text.isEmpty) {
      Get.snackbar("Error", "Required fields are empty", 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";

      if (uid.isEmpty) {
        Get.snackbar("Auth Error", "Please login again");
        return;
      }

      // Prepare data map including the sellerId
      Map<String, dynamic> productData = {
        'sellerId': uid, // Links product to the specific merchant
        'productCode': productCodeController.text.trim(),
        'totalQuantity': int.tryParse(quantityController.text) ?? 0,
        'buyingPrice': double.tryParse(buyingPriceController.text) ?? 0.0,
        'sellingPrice': double.tryParse(sellingPriceController.text) ?? 0.0,
        'sizes': Map<String, int>.from(sizeQuantities),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to the general 'products' collection
      await _firestore.collection('products').add(productData);
      
      _clearForm();
      Get.back();
      Get.snackbar("Success", "Product added successfully", 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Method for updating existing products
  Future<void> updateProduct(String docId) async {
    try {
      isLoading.value = true;
      Map<String, dynamic> updatedData = {
        'productCode': productCodeController.text.trim(),
        'totalQuantity': int.tryParse(quantityController.text) ?? 0,
        'buyingPrice': double.tryParse(buyingPriceController.text) ?? 0.0,
        'sellingPrice': double.tryParse(sellingPriceController.text) ?? 0.0,
        'sizes': Map<String, int>.from(sizeQuantities),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('products').doc(docId).update(updatedData);

      Get.snackbar("Success", "Product updated successfully",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Update Error", e.toString(), backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
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

  void _clearForm() {
    productCodeController.clear();
    quantityController.clear();
    buyingPriceController.clear();
    sellingPriceController.clear();
    sizeQuantities.clear();
  }

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