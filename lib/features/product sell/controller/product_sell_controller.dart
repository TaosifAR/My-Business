import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductSellController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final productCodeController = TextEditingController();
  final sellingPriceController = TextEditingController();
  
  var selectedSaleSizes = <String, int>{}.obs; 
  var totalSaleQuantity = 0.obs;
  var isLoading = false.obs;
  
  // এই লিস্টটি UI-তে (ListView.builder) ব্যবহার করবেন
  var salesList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToSales(); // অ্যাপ চালু হলে সেলস লিস্ট শোনা শুরু করবে
  }

  // ১. রিয়েল-টাইম সেলস লিস্ট শো করার মেথড
void listenToSales() {
    String uid = _auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    // আপনার ইমেজের ডাটা যদি এই পাথে থাকে:
    _firestore
        .collection('users')
        .doc(uid)
        .collection('sales') // অথবা শুধু 'sales' যদি আপনি সরাসরি মেইন কালেকশনে সেভ করেন
        .orderBy('saleDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      salesList.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  // ২. সেল প্রসেস করার মেথড (আপনার আগের কোডের লজিক ঠিক করে দেওয়া হয়েছে)
  Future<void> processSale() async {
    if (productCodeController.text.isEmpty || 
        sellingPriceController.text.isEmpty || 
        selectedSaleSizes.isEmpty) {
      Get.snackbar("Error", "All fields are required", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      String code = productCodeController.text.trim();
      double sellPrice = double.tryParse(sellingPriceController.text.trim()) ?? 0.0;

      // ইনভেন্টরি থেকে প্রোডাক্ট খুঁজে বের করা (Sub-collection পাথ অনুযায়ী)
      var productQuery = await _firestore
          .collection('users')
          .doc(uid)
          .collection('products')
          .where('productCode', isEqualTo: code)
          .limit(1)
          .get();

      if (productQuery.docs.isEmpty) throw "Product not found in inventory!";

      var productDoc = productQuery.docs.first;
      var productData = productDoc.data();
      Map<String, dynamic> inventorySizes = Map<String, dynamic>.from(productData['sizes'] ?? {});
      double buyingPrice = (productData['buyingPrice'] ?? 0.0).toDouble();

      WriteBatch batch = _firestore.batch();

      // স্টক আপডেট লজিক
      selectedSaleSizes.forEach((size, qty) {
        int stockAvailable = (inventorySizes[size] ?? 0).toInt();
        if (stockAvailable < qty) throw "Size $size stock low ($stockAvailable)";
        inventorySizes[size] = stockAvailable - qty;
      });

      // ইনভেন্টরি আপডেট
      batch.update(productDoc.reference, {
        'totalQuantity': (productData['totalQuantity'] ?? 0) - totalSaleQuantity.value,
        'sizes': inventorySizes,
      });

      // সেল রেকর্ড অ্যাড (Sub-collection-এ)
      DocumentReference saleRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('sales')
          .doc();

      batch.set(saleRef, {
        'productCode': code,
        'totalQuantity': totalSaleQuantity.value,
        'selectedSizes': Map<String, int>.from(selectedSaleSizes),
        'sellingPrice': sellPrice,
        'totalProfit': (sellPrice - buyingPrice) * totalSaleQuantity.value,
        'saleDate': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _clearForm();
      Get.back();
      Get.snackbar("Success", "Sale Added", backgroundColor: Colors.green);

    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void updateSizeQuantity(String size, int qty) {
    if (qty > 0) {
      selectedSaleSizes[size] = qty;
    } else {
      selectedSaleSizes.remove(size);
    }
    totalSaleQuantity.value = selectedSaleSizes.values.fold(0, (sum, item) => sum + item);
  }

  void _clearForm() {
    productCodeController.clear();
    sellingPriceController.clear();
    selectedSaleSizes.clear();
    totalSaleQuantity.value = 0;
  }
}