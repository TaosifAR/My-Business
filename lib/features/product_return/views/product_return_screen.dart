import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/product_return/controllers/product_return_controller.dart';

class ProductReturnScreen extends StatelessWidget {
  final ProductReturnController controller = Get.put(ProductReturnController());

  ProductReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Return History", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        }
        if (controller.returnsList.isEmpty) {
          return const Center(child: Text("No returns recorded yet.", style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.returnsList.length,
          itemBuilder: (context, index) {
            var item = controller.returnsList[index];
            
            // তারিখ ফরম্যাট
            DateTime? returnDate = (item['returnDate'] as Timestamp?)?.toDate();
            String formattedDate = returnDate != null 
                ? "${returnDate.day}/${returnDate.month}/${returnDate.year}" 
                : "";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.keyboard_return_rounded, color: Color(0xFF3B82F6)),
                ),
                title: Text("Code: ${item['productCode']} (${item['size']})", 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Returned Qty: ${item['quantity']}\nDate: $formattedDate", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Loss Amount", style: TextStyle(fontSize: 10, color: Colors.redAccent)),
                    Text(
                      "৳${item['lossAmount']?.toStringAsFixed(0) ?? '0'}", 
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}