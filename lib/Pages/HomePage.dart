import 'package:dirgebeya/Pages/Products.dart';
import 'package:dirgebeya/Pages/Widgets/TopProducts.dart';
// import 'package:dirgebeya/Pages/Widgets/statistics_widgets.dart';
import 'package:dirgebeya/Provider/dashboard_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<HomePage> {
  int _selectedIndex = 0;
  String _dropdownValue = 'OverAll';
  String _earningsType = 'monthly'; // Default earnings type
  final String sellerId = '2040'; // Set your seller ID here

  @override
  void initState() {
    super.initState();
    // Fetch initial data after the first frame to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashboardProvider>(context, listen: false);
      provider.fetchOverview();
      provider.fetchEarningsStats(sellerId: sellerId, type: _earningsType);
      provider.fetchTopProducts(); // 👈 Fetch products here
    });
  }

  void _onDropdownChanged(String? newValue) {
    if (newValue == null) return;

    setState(() {
      _dropdownValue = newValue;

      // Update earnings type based on dropdown selection
      switch (newValue) {
        case 'OverAll':
          _earningsType = 'monthly'; // Or set to 'overall' if supported
          break;
        case ' Month':
          _earningsType = 'monthly';
          break;
        case ' Year':
          _earningsType = 'year';
          break;
        default:
          _earningsType = 'monthly';
      }
    });

    // Fetch earnings data for new earnings type
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    provider.fetchEarningsStats(sellerId: sellerId, type: _earningsType);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        final overview = dashboardProvider.overviewData;

        return Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: dashboardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dashboardProvider.error != null
                ? Center(child: Text('Error: ${dashboardProvider.error}'))
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(8.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildEarningsSection(
                              dashboardProvider.earningsData,
                            ),
                            // _buildEarningsSummary(dashboardProvider.earningsData),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Ongoing Orders'),
                            const SizedBox(height: 16),
                            _buildOngoingOrdersGrid(overview),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Completed Orders'),
                            const SizedBox(height: 8),
                            _buildCompletedOrdersList(context,overview),
                            const SizedBox(height: 10),
                          ]),
                        ),
                      ),

                      // StatisticsScreen as a fixed height sliver
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('My Products'),
                              const SizedBox(height: 12),

                              TopProductsGrid(
                                topProducts: dashboardProvider.products,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // PreferredSizeWidget _buildAppBar(BuildContext context) {
  //   return PreferredSize(
  //     preferredSize: const Size.fromHeight(
  //       60,
  //     ), // Set the height of your custom app bar
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //       color: Colors.white,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             children: [
  //               ClipPath(
  //                 child: Container(
  //                   width: 40,
  //                   height: 45,
  //                   padding: const EdgeInsets.all(6.0),
  //                   child: Image.asset(
  //                     'assets/image/logo.png',
  //                     fit: BoxFit.contain,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               const Text(
  //                 'ባለመሪው ነጋዴ',
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Color(0xFFA61E49),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           Stack(
  //             alignment: Alignment.topRight,
  //             children: [
  //               Icon(
  //                 Icons.notifications_none_outlined,
  //                 color: Theme.of(context).primaryColor,
  //                 size: 30,
  //               ),
  //               Container(
  //                 width: 18,
  //                 height: 18,
  //                 margin: const EdgeInsets.only(top: 2, right: 2),
  //                 decoration: BoxDecoration(
  //                   color: Colors.red,
  //                   shape: BoxShape.circle,
  //                   border: Border.all(color: Colors.white, width: 2),
  //                 ),
  //                 child: const Center(
  //                   child: Text(
  //                     '0',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 10,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


PreferredSizeWidget _buildAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipPath(
                child: Container(
                  width: 40,
                  height: 45,
                  padding: const EdgeInsets.all(6.0),
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ባለመሪው ነጋዴ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineLarge?.color ?? const Color(0xFFA61E49),
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
            // Icon(Icons.monetization_on, color: Colors.green, size: 28),
            // SizedBox(width: 8),
            Text(
              'Business Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 252, 252, 252),
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.white),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _dropdownValue,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onChanged: _onDropdownChanged,
              items: <String>['OverAll', ' Month', ' Year']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(color: Colors.blue),
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
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1455AC),
        ),
      );
    },
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

  Widget _buildEarningsSection(Map<String, dynamic>? earningsData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsHeader(),
            const SizedBox(height: 20),
            _buildEarningsSummary(earningsData),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(Map<String, dynamic>? earningsData) {
    if (earningsData == null) {
      return const SizedBox(); // show nothing if null
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/transaction");
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${earningsData['total_earning'] ?? '0'} ETB',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/transaction");
            },
            child: CircleAvatar(
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build a single card in the ongoing orders grid.
  // Widget _buildOrderCard({
  //   required String count,
  //   required String label,
  //   required Color color,
  //   required Color lightColor,
  // }) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: color,
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Stack(
  //       clipBehavior: Clip.hardEdge,
  //       children: [
  //         Positioned(
  //           right: -20,
  //           top: -20,
  //           child: Container(
  //             width: 100,
  //             height: 100,
  //             decoration: BoxDecoration(
  //               color: lightColor.withOpacity(0.5),
  //               shape: BoxShape.circle,
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 count,
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 35,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const Spacer(),
  //               Text(
  //                 label,
  //                 style: const TextStyle(color: Colors.white, fontSize: 14),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


Widget _buildOrderCard({
  required String count,
  required String label,
  required Color color,
  required Color lightColor,
}) {
  final theme = Theme.of(context);
  final cardColor = theme.brightness == Brightness.dark ? lightColor : color;

  return Container(
    decoration: BoxDecoration(
      color: cardColor,
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
              color: cardColor.withOpacity(0.5),
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
 Widget _buildCompletedOrdersList(BuildContext context, Map<String, dynamic>? data) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    children: [
      _buildCompletedOrderItem(
        iconData: Icons.do_not_disturb_on_total_silence,
        iconColor: Colors.green,
        label: 'Total',
        count: data?['total_orders'].toString() ?? '0',
        countColor: isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
        countTextColor: isDark ? Colors.green.shade300 : Colors.green.shade800,
        context: context,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.check_circle,
        iconColor: Colors.green,
        label: 'Delivered',
        count: data?['completed_orders'].toString() ?? '0',
        countColor: isDark ? Colors.green.withOpacity(0.2) : Colors.green.withOpacity(0.1),
        countTextColor: isDark ? const Color.fromARGB(255, 188, 250, 191) : Colors.green.shade800, context: context,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.cancel,
        iconColor: Colors.red,
        label: 'Cancelled',
        count: data?['pending_orders'].toString() ?? '0',
        countColor: isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1),
        countTextColor: isDark ? Colors.red.shade300 : Colors.red.shade800,
        context: context,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.assignment_return,
        iconColor: Colors.orange.shade700,
        label: 'Return',
        count: data?['refunded_orders'].toString() ?? '0',
        countColor: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        countTextColor: isDark ? Colors.white70 : Colors.black54,
        context: context,
      ),
      _buildCompletedOrderItem(
        iconData: Icons.warning_amber_rounded,
        iconColor: Colors.red.shade700,
        label: 'Failed to Delivery',
        count: data?['failed_orders'].toString() ?? '0',
        countColor: isDark ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1),
        countTextColor: isDark ? Colors.red.shade300 : Colors.red.shade800,
        context: context,
      ),
    ],
  );
}

  /// Helper to build a single item in the completed orders list.
 Widget _buildCompletedOrderItem({
  required BuildContext context,
  required IconData iconData,
  required Color iconColor,
  required String label,
  required String count,
  required Color countColor,
  required Color countTextColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

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
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
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
