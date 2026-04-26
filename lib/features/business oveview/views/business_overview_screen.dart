import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Note: Ensure your import path is correct
import 'package:my_business/features/business%20oveview/controllers/business_overview_controller.dart';

class BusinessReportScreen extends StatelessWidget {
  final controller = Get.put(BusinessReportController());

  BusinessReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text("Analytics Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () => controller.calculateReport(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Performance Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // --- Graph Section ---
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue() * 1.2, // dynamic height
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0: return const Text('Inv', style: TextStyle(fontSize: 12));
                              case 1: return const Text('Sale', style: TextStyle(fontSize: 12));
                              case 2: return const Text('Profit', style: TextStyle(fontSize: 12));
                              case 3: return const Text('Loss', style: TextStyle(fontSize: 12));
                              default: return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeGroupData(0, controller.totalInvestment.value, Colors.blue),
                      _makeGroupData(1, controller.totalSales.value, Colors.orange),
                      _makeGroupData(2, controller.netProfit.value, Colors.green), // Real Profit
                      _makeGroupData(3, controller.totalLoss.value, Colors.red),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- Profit Percentage Highlight ---
              _buildProfitCard(),

              const SizedBox(height: 30),
              const Text("Detailed Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              _buildStatTile("Total Investment", controller.totalInvestment.value, Colors.blue),
              _buildStatTile("Total Sales", controller.totalSales.value, Colors.orange),
              _buildStatTile("Net Profit (After Loss)", controller.netProfit.value, Colors.green),
              _buildStatTile("Total Return Loss", controller.totalLoss.value, Colors.red),
            ],
          ),
        );
      }),
    );
  }

  // --- Percentage Indicator Card ---
  Widget _buildProfitCard() {
    double percentage = controller.profitPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: percentage >= 0 ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: percentage >= 0 ? Colors.green.shade100 : Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(
            percentage >= 0 ? Icons.trending_up : Icons.trending_down,
            color: percentage >= 0 ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Investment Growth", style: TextStyle(color: Colors.black54)),
              Text(
                "${percentage.toStringAsFixed(2)}%",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y < 0 ? 0 : y, // Prevent negative bars from breaking UI
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxValue() * 1.2,
            color: Colors.grey.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  double _getMaxValue() {
    List<double> values = [
      controller.totalInvestment.value,
      controller.totalSales.value,
      controller.netProfit.value,
      controller.totalLoss.value,
    ];
    double max = values.reduce((curr, next) => curr > next ? curr : next);
    return max == 0 ? 1000 : max; // Default if no data
  }

  Widget _buildStatTile(String title, double amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text("৳${amount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}