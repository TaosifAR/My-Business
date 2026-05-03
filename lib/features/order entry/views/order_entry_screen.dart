import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/order%20entry/controllers/order_entry_controller.dart';
import 'package:my_business/widgets/custom_appbar.dart';

class OrderEntryScreen extends StatelessWidget {
  final OrderController controller = Get.put(OrderController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  OrderEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
          title: "Order Management",
          showBackButton: true,
          scaffoldKey: _scaffoldKey),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F172A),
        onPressed: () => _showOrderForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Pending Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Obx(() {
              if (controller.ordersList.isEmpty) {
                return const Center(child: Text("No pending orders."));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: controller.ordersList.length,
                itemBuilder: (context, index) =>
                    _buildOrderCard(controller.ordersList[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    Map<String, dynamic> sizes = order['sizes'] ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['customerName'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Price: ${order['sellingPrice']}",
                  style: const TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            children: sizes.entries
                .map((e) => Chip(
                      label: Text("${e.key}: ${e.value}",
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.grey.shade100,
                    ))
                .toList(),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.markAsSold(order),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Sold"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.showReturnDialog(order),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("Return"),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showOrderForm(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("New Order Entry",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildTextField(controller.customerNameController,
                  "Customer Name", Icons.person),
              const SizedBox(height: 10),
              _buildTextField(controller.productCodeController, "Product Code",
                  Icons.qr_code),
              const SizedBox(height: 15),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Sizes & Qty",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                    spacing: 8,
                    children: ["S", "M", "L", "XL", "XXL"].map((size) {
                      bool isSelected =
                          controller.sizeQuantities.containsKey(size);
                      return ChoiceChip(
                        label: Text(isSelected
                            ? "$size (${controller.sizeQuantities[size]})"
                            : size),
                        selected: isSelected,
                        onSelected: (val) =>
                            controller.showQuantityInputDialog(size),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 15),
              _buildTextField(controller.sellingPriceController,
                  "Per Product Selling Price", Icons.payments,
                  type: TextInputType.number),
              const SizedBox(height: 20),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.saveOrder(),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save Order",
                              style: TextStyle(color: Colors.white)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
