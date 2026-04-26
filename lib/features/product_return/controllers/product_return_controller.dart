import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductReturnController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final productCodeController = TextEditingController();
  final quantityController = TextEditingController();
  
  var selectedSize = "".obs;
  var isLoading = false.obs;
  var returnsList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    listenToReturns();
  }

  void listenToReturns() {
    String uid = _auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    _firestore
        .collection('users').doc(uid).collection('returns')
        .orderBy('returnDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      returnsList.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['docId'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> processReturn() async {
    if (productCodeController.text.isEmpty || 
        quantityController.text.isEmpty || 
        selectedSize.value.isEmpty) {
      Get.snackbar("Error", "Please fill all fields", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      String code = productCodeController.text.trim();
      int returnQty = int.tryParse(quantityController.text.trim()) ?? 0;

      // ১. ইনভেন্টরি থেকে প্রোডাক্ট চেক করা
      var productQuery = await _firestore
          .collection('users').doc(uid).collection('products')
          .where('productCode', isEqualTo: code).limit(1).get();

      if (productQuery.docs.isEmpty) throw "Product Code '$code' not found!";

      var productDoc = productQuery.docs.first;
      var productData = productDoc.data();
      double sellingPrice = (productData['sellingPrice'] ?? 0.0).toDouble();

      Map<String, dynamic> sizes = Map<String, dynamic>.from(productData['sizes'] ?? {});
      int currentSizeQty = (sizes[selectedSize.value] ?? 0).toInt();
      
      // ২. স্টক বাড়ানোর প্রস্তুতি
      sizes[selectedSize.value] = currentSizeQty + returnQty;
      double lossAmount = sellingPrice * returnQty; // লস ক্যালকুলেশন

      WriteBatch batch = _firestore.batch();
      
      // ৩. ইনভেন্টরি আপডেট (স্টক যোগ হচ্ছে)
      batch.update(productDoc.reference, {
        'totalQuantity': FieldValue.increment(returnQty),
        'sizes': sizes,
      });

      // ৪. রিটার্ন হিস্ট্রিতে লস সহ ডাটা সেভ করা
      DocumentReference returnRef = _firestore.collection('users').doc(uid).collection('returns').doc();
      batch.set(returnRef, {
        'productCode': code,
        'quantity': returnQty,
        'size': selectedSize.value,
        'lossAmount': lossAmount,
        'returnDate': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      
      Get.back(); 
      Get.snackbar("Success", "Returned & Stock Restored", 
          backgroundColor: const Color(0xFF3B82F6), colorText: Colors.white);
      _clearForm();
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  void _clearForm() {
    productCodeController.clear();
    quantityController.clear();
    selectedSize.value = "";
  }
}