import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/product%20sell/controller/product_sell_controller.dart';
import 'package:my_business/widgets/custom_appbar.dart'; // আপনার কাস্টম অ্যাপবার

class ProductSellScreen extends StatelessWidget {
  final ProductSellController controller = Get.put(ProductSellController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ProductSellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Sales History",
        showBackButton: true,
        scaffoldKey: _scaffoldKey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Recent Sales History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }
                if (controller.salesList.isEmpty) {
                  return const Center(child: Text("No sales recorded yet.", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  itemCount: controller.salesList.length,
                  itemBuilder: (context, index) {
                    var sale = controller.salesList[index];
                    return _buildSaleCard(sale);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildSaleCard(var sale) {
    // Firestore Timestamp থেকে Date বের করা
    DateTime? saleDate = (sale['saleDate'] as Timestamp?)?.toDate();
    String formattedDate = saleDate != null 
        ? "${saleDate.day} April ${saleDate.year}" 
        : "No Date";

    // ১. সাইজ ম্যাপ থেকে টেক্সট তৈরি করা (যেমন: M: 5, S: 3)
    Map<String, dynamic> sizesMap = Map<String, dynamic>.from(sale['sizes'] ?? {});
    String sizeDetails = sizesMap.entries.map((e) => "${e.key}(${e.value})").join(", ");

    // ২. মোট কোয়ান্টিটি ক্যালকুলেট করা (যেহেতু আলাদা ফিল্ড নেই)
    int totalQty = sizesMap.values.fold(0, (sum, val) => sum + (int.tryParse(val.toString()) ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          "Code: ${sale['productCode'] ?? 'N/A'}", 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // আপনার চাহিদা মতো সাইজ ফরম্যাট: M(5), S(3)
            Text("Sizes: $sizeDetails", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text("Total Qty: $totalQty | Price: ৳${sale['sellingPrice'] ?? 0}"),
            Text("Date: $formattedDate", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
             Text(
              sale['status']?.toString().toUpperCase() ?? "", 
              style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 5),
            Text(
              "৳${sale['sellingPrice'] ?? 0}", 
              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}