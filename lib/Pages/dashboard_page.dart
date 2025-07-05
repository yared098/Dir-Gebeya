import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPeriod = 'Weekly';
  bool isLoadingOrders = true;

  final Map<String, dynamic> overview = {
    "total_earning": 0,
    "total_products": 337,
    "total_orders": 120,
    "pending_orders": 25,
    "completed_orders": 50,
    "return_orders": 20,
    "failed_orders": 15,
  };

  final Map<String, dynamic> earningsByPeriod = {
    "Daily": 150,
    "Weekly": 1200,
    "Monthly": 4500,
    "Yearly": 52000,
  };

  final List<String> periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoadingOrders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📊 Business Analysis Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Business Analysis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedPeriod,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                          items: periods.map((String value) {
                            return DropdownMenuItem(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() => selectedPeriod = newValue);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.bar_chart, color: Colors.blue, size: 32),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$selectedPeriod Earnings",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Total: ETB ${earningsByPeriod[selectedPeriod]}.00",
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔷 Ongoing Orders Grid
            const Text(
              "Ongoing Orders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridTile('1', 'Pending Orders', const Color(0xFF042E50)),
                _buildGridTile('1', 'Packing Orders', const Color(0xFF4E7A9E)),
                _buildGridTile('4', 'Confirmed', Colors.green),
                _buildGridTile('2', 'Out For Delivery', Colors.red),
              ],
            ),

            const SizedBox(height: 32),

            /// 📋 Orders Summary
            const Text(
              "Completed Orders",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),

            if (isLoadingOrders)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              _buildOrderSummaryTile("Confirmed Orders", overview["completed_orders"], Colors.green),
              _buildOrderSummaryTile("Pending Orders", overview["pending_orders"], Colors.orange),
              _buildOrderSummaryTile("Returned Orders", overview["return_orders"], Colors.deepOrange),
              _buildOrderSummaryTile("Failed Orders", overview["failed_orders"], Colors.red.shade900),
              _buildOrderSummaryTile("Out for Delivery", 10, Colors.blue.shade300),
              _buildOrderSummaryTile("Packaging", 8, Colors.blue.shade100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryTile(String title, int count, Color color) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Icon(Icons.circle, color: color, size: 18),
          ],
        ),
        title: Text(title),
        trailing: Text(
          '$count',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
