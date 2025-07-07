import 'package:dirgebeya/Provider/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _dropdownValue = 'OverAll';

@override
Widget build(BuildContext context) {
  return Consumer<DashboardProvider>(
    builder: (context, dashboardProvider, _) {
      final overview = dashboardProvider.overviewData;
      print("dashboard"+overview.toString());

      return Scaffold(
        body: SafeArea(
          child: dashboardProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : dashboardProvider.error != null
                  ? Center(child: Text('Error: ${dashboardProvider.error}'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAppBar(context),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAnalyticsHeader(),
                                const SizedBox(height: 20),
                                _buildSectionTitle('Ongoing Orders'),
                                const SizedBox(height: 16),
                                _buildOngoingOrdersGrid(overview),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Completed Orders'),
                                const SizedBox(height: 8),
                                _buildCompletedOrdersList(overview),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      );
    },
  );
}


  /// Builds the custom app bar.
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipPath(
                // If you have a custom shape, keep this enabled:
                // clipper: HexagonClipper(),
                child: Container(
                  width: 40,
                  height: 45,
                  // color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(
                      6.0,
                    ), // Adjust padding as needed
                    child: Image.asset(
                      'assets/image/logo.png', // ✅ Your logo path
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              const Text(
                'ባለመሪው ነጋዴ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA61E49),
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 2, right: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the "Business Analytics" header with the dropdown.
  Widget _buildAnalyticsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              'Business Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dropdownValue,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _dropdownValue = newValue;
                });
              },
              items: <String>['OverAll', 'This Month', 'This Year']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the title for a section.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1455AC),
      ),
    );
  }

  /// Builds the 2x2 grid for ongoing orders.
  Widget _buildOngoingOrdersGrid(Map<String, dynamic>? data) {
  return GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.5,
    children: [
      _buildOrderCard(
        count: data?['total_orders'].toString() ?? '0',
        label: 'Total Orders',
        color: const Color(0xFF2E4E8A),
        lightColor: const Color(0xFF4A6AB2),
      ),
      _buildOrderCard(
        count: data?['pending_orders'].toString() ?? '0',
        label: 'Pending Orders',
        color: const Color(0xFF2E4E8A),
        lightColor: const Color(0xFF4A6AB2),
      ),
      _buildOrderCard(
        count: data?['completed_orders'].toString() ?? '0',
        label: 'Completed Orders',
        color: const Color(0xFF00A36C),
        lightColor: const Color(0xFF28B47E),
      ),
      _buildOrderCard(
        count: data?['refunded_orders'].toString() ?? '0',
        label: 'Refund Delivery',
        color: const Color(0xFFD9534F),
        lightColor: const Color(0xFFE0635F),
      ),
    ],
  );
}

  /// Helper to build a single card in the ongoing orders grid.
  Widget _buildOrderCard({
    required String count,
    required String label,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: lightColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of completed order statuses.
  Widget _buildCompletedOrdersList(Map<String, dynamic>? data) {
  return Column(
    children: [
      _buildCompletedOrderItem(
        iconData: Icons.do_not_disturb_on_total_silence,
        iconColor: Colors.green,
        label: 'Total ',
        count: data?['total_orders'].toString() ?? '0',
        countColor: Colors.green.withOpacity(0.1),
        countTextColor: Colors.green.shade800,
      ),
       _buildCompletedOrderItem(
        iconData: Icons.check_circle,
        iconColor: Colors.green,
        label: 'Delivered',
        count: data?['completed_orders'].toString() ?? '0',
        countColor: Colors.green.withOpacity(0.1),
        countTextColor: Colors.green.shade800,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.cancel,
        iconColor: Colors.red,
        label: 'Cancelled',
        count: data?['pending_orders'].toString() ?? '0',
        countColor: Colors.red.withOpacity(0.1),
        countTextColor: Colors.red.shade800,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.assignment_return,
        iconColor: Colors.orange.shade700,
        label: 'Return',
        count: data?['refunded_orders'].toString() ?? '0',
        countColor: Colors.grey.withOpacity(0.2),
        countTextColor: Colors.black54,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.warning_amber_rounded,
        iconColor: Colors.red.shade700,
        label: 'Failed to Delivery',
        count: data?['failed_orders'].toString() ?? '0',
        countColor: Colors.red.withOpacity(0.1),
        countTextColor: Colors.red.shade800,
      ),
    ],
  );
}


  /// Helper to build a single item in the completed orders list.
  Widget _buildCompletedOrderItem({
    required IconData iconData,
    required Color iconColor,
    required String label,
    required String count,
    required Color countColor,
    required Color countTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(iconData, color: iconColor, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: countColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: countTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
