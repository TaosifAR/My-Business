import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final customerNameController = TextEditingController();
  final productCodeController = TextEditingController();
  final sellingPriceController = TextEditingController();
  
  var sizeQuantities = <String, int>{}.obs; 
  var ordersList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenToOrders();
  }

  // Logic 1: Stock Validation (Same as before)
  Future<bool> validateStockBeforeAdding(String code, String size, int requestedQty) async {
    String uid = _auth.currentUser?.uid ?? "";
    try {
      var productQuery = await _firestore
          .collection('users').doc(uid).collection('products')
          .where('productCode', isEqualTo: code).get();

      if (productQuery.docs.isEmpty) {
        Get.snackbar("Error", "Product Code not found!", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      var productData = productQuery.docs.first.data();
      Map<String, dynamic> inventorySizes = Map<String, dynamic>.from(productData['sizes'] ?? {});

      int availableQty = inventorySizes[size] ?? 0;
      if (availableQty < requestedQty) {
        Get.snackbar("Error", "Insufficient stock! Available: $availableQty", backgroundColor: Colors.orange);
        return false;
      }
      return true;
    } catch (e) { return false; }
  }
  // --- Logic 4: Process Return (Restore Stock & Record Loss) ---
  Future<void> processOrderReturn(Map<String, dynamic> orderData, String returnSize, int returnQty, double loss) async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      String pCode = orderData['productCode'];
      String orderDocId = orderData['docId'];

      // ১. ইনভেন্টরি থেকে প্রোডাক্ট খুঁজে বের করা
      var productQuery = await _firestore
          .collection('users').doc(uid).collection('products')
          .where('productCode', isEqualTo: pCode).limit(1).get();

      if (productQuery.docs.isEmpty) throw "Product not found in inventory!";

      var productDoc = productQuery.docs.first;
      var inventoryData = productDoc.data();
      Map<String, dynamic> inventorySizes = Map<String, dynamic>.from(inventoryData['sizes'] ?? {});

      WriteBatch batch = _firestore.batch();

      // ২. ইনভেন্টরিতে স্টক ফেরত পাঠানো (Plus করা)
      if (inventorySizes.containsKey(returnSize)) {
        inventorySizes[returnSize] = (inventorySizes[returnSize] ?? 0) + returnQty;
        batch.update(productDoc.reference, {
          'sizes': inventorySizes,
          'totalQuantity': (inventoryData['totalQuantity'] ?? 0) + returnQty,
        });
      }

      // ৩. রিটার্ন কালেকশনে ডাটা সেভ করা
      DocumentReference returnRef = _firestore.collection('users').doc(uid).collection('returns').doc();
      batch.set(returnRef, {
        'productCode': pCode,
        'customerName': orderData['customerName'],
        'size': returnSize,
        'quantity': returnQty,
        'lossAmount': loss,
        'returnDate': FieldValue.serverTimestamp(),
      });

      // ৪. পেন্ডিং লিস্ট আপডেট করা
      // যদি সব প্রোডাক্ট রিটার্ন হয় তবে ডিলিট, নাহলে শুধু ওই সাইজের কোয়ান্টিটি কমিয়ে পেন্ডিং-এ রাখা
      Map<String, dynamic> pendingSizes = Map<String, dynamic>.from(orderData['sizes']);
      int currentPendingQty = pendingSizes[returnSize] ?? 0;
      
      if (currentPendingQty <= returnQty) {
        pendingSizes.remove(returnSize);
      } else {
        pendingSizes[returnSize] = currentPendingQty - returnQty;
      }

      DocumentReference orderRef = _firestore.collection('users').doc(uid).collection('pending_orders').doc(orderDocId);
      if (pendingSizes.isEmpty) {
        batch.delete(orderRef);
      } else {
        batch.update(orderRef, {'sizes': pendingSizes});
      }

      await batch.commit();
      Get.back(); // ডায়ালগ বন্ধ করা
      Get.snackbar("Success", "Product returned and stock restored", backgroundColor: Colors.blue, colorText: Colors.white);
      
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // রিটার্ন ডায়ালগ দেখানোর ফাংশন
  void showReturnDialog(Map<String, dynamic> order) {
    String selectedSize = (order['sizes'] as Map).keys.first;
    final returnQtyController = TextEditingController(text: "1");
    final lossController = TextEditingController(text: "0");

    Get.defaultDialog(
      title: "Return Product",
      content: Column(
        children: [
          const Text("Select size to return:"),
          DropdownButtonFormField<String>(
            value: selectedSize,
            items: (order['sizes'] as Map).keys.map((s) => DropdownMenuItem<String>(value: s.toString(), child: Text(s))).toList(),
            onChanged: (val) => selectedSize = val!,
          ),
          TextField(controller: returnQtyController, decoration: const InputDecoration(labelText: "Return Quantity"), keyboardType: TextInputType.number),
          TextField(controller: lossController, decoration: const InputDecoration(labelText: "Loss Amount (Optional)"), keyboardType: TextInputType.number),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {
          int qty = int.tryParse(returnQtyController.text) ?? 0;
          double loss = double.tryParse(lossController.text) ?? 0.0;
          if (qty > 0) {
            processOrderReturn(order, selectedSize, qty, loss);
          }
        },
        child: const Text("Confirm Return"),
      ),
      cancel: OutlinedButton(onPressed: () => Get.back(), child: const Text("Cancel")),
    );
  }

  // --- Logic 2: Save Order and Deduct Stock IMMEDIATELY ---
  Future<void> saveOrder() async {
    if (customerNameController.text.isEmpty || sizeQuantities.isEmpty) {
      Get.snackbar("Error", "Required fields empty", backgroundColor: Colors.redAccent);
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      String pCode = productCodeController.text.trim();

      // ১. ইনভেন্টরি থেকে প্রোডাক্ট খুঁজে বের করা
      var productQuery = await _firestore
          .collection('users').doc(uid).collection('products')
          .where('productCode', isEqualTo: pCode).limit(1).get();

      if (productQuery.docs.isEmpty) throw "Product not found!";

      var productDoc = productQuery.docs.first;
      var inventoryData = productDoc.data();
      Map<String, dynamic> currentInventorySizes = Map<String, dynamic>.from(inventoryData['sizes'] ?? {});
      
      WriteBatch batch = _firestore.batch();
      int totalToDeduct = 0;

      // ২. ইনভেন্টরি সাইজ আপডেট করার প্রস্তুতি
      sizeQuantities.forEach((size, qty) {
        if (currentInventorySizes.containsKey(size)) {
          currentInventorySizes[size] = (currentInventorySizes[size] ?? 0) - qty;
          totalToDeduct += qty;
        }
      });

      // ৩. ইনভেন্টরি আপডেট (Deducting stock now)
      batch.update(productDoc.reference, {
        'sizes': currentInventorySizes,
        'totalQuantity': (inventoryData['totalQuantity'] ?? 0) - totalToDeduct,
      });

      // ৪. পেন্ডিং অর্ডার কালেকশনে ডাটা অ্যাড করা
      DocumentReference orderRef = _firestore.collection('users').doc(uid).collection('pending_orders').doc();
      batch.set(orderRef, {
        'customerName': customerNameController.text.trim(),
        'productCode': pCode,
        'sellingPrice': double.tryParse(sellingPriceController.text) ?? 0.0,
        'sizes': Map<String, int>.from(sizeQuantities),
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // একসাথেই সব কাজ হবে

      _clearForm();
      Get.back();
      Get.snackbar("Success", "Order added and Stock deducted", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // --- Logic 3: Just Move to Sales (No Stock Deduction here) ---
  Future<void> markAsSold(Map<String, dynamic> orderData) async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      String orderDocId = orderData['docId'];

      WriteBatch batch = _firestore.batch();

      // ১. শুধুমাত্র সেলস কালেকশনে ডাটা কপি করা
      DocumentReference saleRef = _firestore.collection('users').doc(uid).collection('sales').doc();
      batch.set(saleRef, {
        ...orderData,
        'saleDate': FieldValue.serverTimestamp(),
        'status': 'sold',
      });

      // ২. পেন্ডিং কালেকশন থেকে ডিলিট করা
      DocumentReference orderRef = _firestore.collection('users').doc(uid).collection('pending_orders').doc(orderDocId);
      batch.delete(orderRef);

      await batch.commit();
      
      Get.snackbar("Sold", "Moved to Sales History", backgroundColor: Colors.blue, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void listenToOrders() {
    String uid = _auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;
    _firestore
        .collection('users').doc(uid).collection('pending_orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      ordersList.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  void _clearForm() {
    customerNameController.clear();
    productCodeController.clear();
    sellingPriceController.clear();
    sizeQuantities.clear();
  }

  void showQuantityInputDialog(String size) async {
    if (productCodeController.text.trim().isEmpty) {
      Get.snackbar("Input Required", "Please enter Product Code first", backgroundColor: Colors.amber);
      return;
    }
    final qtyInputController = TextEditingController(
        text: sizeQuantities.containsKey(size) ? sizeQuantities[size].toString() : "");

    Get.defaultDialog(
      title: "Quantity for $size",
      content: TextField(
        controller: qtyInputController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: "Enter quantity"),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          int qty = int.tryParse(qtyInputController.text) ?? 0;
          if (qty > 0) {
            bool isValid = await validateStockBeforeAdding(productCodeController.text.trim(), size, qty);
            if (isValid) {
              sizeQuantities[size] = qty;
              Get.back();
            }
          } else {
            sizeQuantities.remove(size);
            Get.back();
          }
        },
        child: const Text("Set"),
      ),
    );
  }
}