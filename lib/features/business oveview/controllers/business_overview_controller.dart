import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BusinessReportController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var totalInvestment = 0.0.obs;
  var totalSales = 0.0.obs;
  var totalProfit = 0.0.obs; // Gross Profit from sales
  var totalLoss = 0.0.obs; // Loss from returns
  var netProfit = 0.0.obs; // Real profit (Profit - Loss)

  var isLoading = false.obs;

  // Percentage calculations for Graph
  double get profitPercentage => totalInvestment.value > 0
      ? (netProfit.value / totalInvestment.value) * 100
      : 0.0;

  @override
  void onInit() {
    super.onInit();
    calculateReport();
  }

  Future<void> calculateReport() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? "";
      if (uid.isEmpty) return;

      // --- 1. Investment Calculation ---
      var productSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('products')
          .get();

      double currentStockInvestment = 0;

      for (var doc in productSnap.docs) {
        // doc.data() k ekta Map-e niye neoa safe
        Map<String, dynamic> data = doc.data();

        // data['totalQuantity'] use koro, doc['totalQuantity'] na
        double buyPrice = (data['buyingPrice'] ?? 0).toDouble();
        int qty = (data['totalQuantity'] ?? 0);

        currentStockInvestment += (buyPrice * qty);
      }

      // --- 2. Sales & Profit Calculation ---
// --- 2. Sales & Profit Calculation Section ---
      var salesSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sales')
          .get();

      double salesRevenue = 0;
      double grossProfit = 0;

      for (var doc in salesSnap.docs) {
        Map<String, dynamic> data = doc.data();

        // Jodi totalQuantity field-ti na thake, tobe sizes map theke quantity jog korbo
        int sQty = 0;
        if (data.containsKey('totalQuantity')) {
          sQty = (data['totalQuantity'] ?? 0).toInt();
        } else if (data.containsKey('sizes')) {
          // Sizes map-er sob value (quantity) jog kora hocche
          Map<String, dynamic> sizesMap =
              Map<String, dynamic>.from(data['sizes']);
          for (var qty in sizesMap.values) {
            sQty += (qty as int);
          }
        }

        double sPrice = (data['sellingPrice'] ?? 0).toDouble();
        double profit = (data['totalProfit'] ?? 0).toDouble();

        salesRevenue += sPrice;
        grossProfit += profit;
      }

// Update observables
      totalSales.value = salesRevenue;
      totalProfit.value = grossProfit;

      // --- 3. Return Loss Calculation ---
      var returnSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('returns')
          .get();

      double lossFromReturns = 0;
      for (var doc in returnSnap.docs) {
        Map<String, dynamic> data = doc.data();
        lossFromReturns += (data['lossAmount'] ?? 0).toDouble();
      }

      // Assigning values to observables
      totalInvestment.value = currentStockInvestment;
      totalSales.value = salesRevenue;
      totalProfit.value = grossProfit;
      totalLoss.value = lossFromReturns;
      netProfit.value = grossProfit - lossFromReturns;
    } catch (e) {
      print("Error in calculateReport: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
