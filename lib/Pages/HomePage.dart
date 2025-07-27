import 'package:barcode_widget/barcode_widget.dart';

import 'package:dirgebeya/Pages/Widgets/TopProducts.dart';
// import 'package:dirgebeya/Pages/Widgets/statistics_widgets.dart';
import 'package:dirgebeya/Provider/dashboard_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<HomePage> {
  String _dropdownValue = 'OverAll';
  String _earningsType = 'monthly';
  final String sellerId = '2040';

 

  @override
void initState() {
  super.initState();

  // Fetch initial data after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    // ✅ Only fetch if not already loaded
    if (provider.overviewData == null) {
      provider.fetchOverview();
    }

    if (provider.earningsData == null || provider.earningsData!.isEmpty) {
      provider.fetchEarningsStats(sellerId: sellerId, type: _earningsType);
    }

    if (provider.products == null || provider.products!.isEmpty) {
      provider.fetchTopProducts();
    }
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
          : RefreshIndicator(
              onRefresh: () async {
                await dashboardProvider.fetchOverview();
                await dashboardProvider.fetchEarningsStats(
                  sellerId: sellerId,
                  type: _earningsType,
                );
                await dashboardProvider.fetchTopProducts();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // ⚠️ required
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildEarningsSection(dashboardProvider.earningsData),
                        _buildRowCards(dashboardProvider.overviewData),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Ongoing Orders'),
                        const SizedBox(height: 16),
                        _buildOngoingOrdersGrid(overview),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Completed Orders'),
                        const SizedBox(height: 8),
                        _buildCompletedOrdersList(context, overview),
                        const SizedBox(height: 10),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('My Products'),
                          const SizedBox(height: 12),
                          TopProductsGrid(topProducts: dashboardProvider.products),
                        ],
                      ),
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

  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        margin: const EdgeInsets.only(top: 13), // 👈 Add this line
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
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
                    color:
                        Theme.of(context).textTheme.headlineLarge?.color ??
                        const Color(0xFFA61E49),
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

 Widget _buildRowCards(Map<String, dynamic>? earningsData) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vendor Tools Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildCircularIconsRow(context, earningsData),
        ],
      ),
    ),
  );
}

  Widget _buildCircularIconsRow(
    BuildContext context,
    Map<String, dynamic>? data,
  ) {
    if (data == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildIconCard(
          context,
          title: 'Promo',
          value: '${data['advert'] ?? '0'}',
          icon: Icons.campaign,
          route: '/advert',
        ),
        _buildIconCard(
          context,
          title: 'My Shop',
          value: '${data['vendor_store'] ?? '0'}',
          icon: Icons.store,
          route: '/vendorstore',
        ),
        _buildIconCard(
          context,
          title: 'Referral',
          value: '${data['referal'] ?? '0'}',
          icon: Icons.group_add,
          route: '/referral',
        ),
      ],
    );
  }

 Widget _buildIconCard(
  BuildContext context, {
  required String title,
  required String value,
  required IconData icon,
  required String route,
  Color cardColor = const Color.fromARGB(255, 250, 250, 250), // Optional card background
}) {
  return GestureDetector(
    onTap: () => _showInfoDialog(context, title, value, icon),
    child: Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

 
  void _showInfoDialog(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    bool isBarcode =
        (title == 'Referral' || title == 'My Shop') &&
        Uri.tryParse(value)?.hasAbsolutePath == true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(icon, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Show QR code if it's a URL
                isBarcode
                    ? Column(
                        children: [
                          BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: value,
                            width: 200,
                            height: 200,
                            color: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Scan or tap to open",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Share.share(value, subject: 'Check this out!');
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share Link'),
                          ),
                        ],
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
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
  Widget _buildCompletedOrdersList(
    BuildContext context,
    Map<String, dynamic>? data,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildCompletedOrderItem(
          iconData: Icons.do_not_disturb_on_total_silence,
          iconColor: Colors.green,
          label: 'Total',
          count: data?['total_orders'].toString() ?? '0',
          countColor: isDark
              ? Colors.green.withOpacity(0.2)
              : Colors.green.withOpacity(0.1),
          countTextColor: isDark
              ? Colors.green.shade300
              : Colors.green.shade800,
          context: context,
        ),
        _buildCompletedOrderItem(
          iconData: Icons.check_circle,
          iconColor: Colors.green,
          label: 'Delivered',
          count: data?['completed_orders'].toString() ?? '0',
          countColor: isDark
              ? Colors.green.withOpacity(0.2)
              : Colors.green.withOpacity(0.1),
          countTextColor: isDark
              ? const Color.fromARGB(255, 188, 250, 191)
              : Colors.green.shade800,
          context: context,
        ),
        _buildCompletedOrderItem(
          iconData: Icons.cancel,
          iconColor: Colors.red,
          label: 'Cancelled',
          count: data?['pending_orders'].toString() ?? '0',
          countColor: isDark
              ? Colors.red.withOpacity(0.2)
              : Colors.red.withOpacity(0.1),
          countTextColor: isDark ? Colors.red.shade300 : Colors.red.shade800,
          context: context,
        ),
        _buildCompletedOrderItem(
          iconData: Icons.assignment_return,
          iconColor: Colors.orange.shade700,
          label: 'Return',
          count: data?['refunded_orders'].toString() ?? '0',
          countColor: isDark
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          countTextColor: isDark ? Colors.white70 : Colors.black54,
          context: context,
        ),
        _buildCompletedOrderItem(
          iconData: Icons.warning_amber_rounded,
          iconColor: Colors.red.shade700,
          label: 'Failed to Delivery',
          count: data?['failed_orders'].toString() ?? '0',
          countColor: isDark
              ? Colors.red.withOpacity(0.2)
              : Colors.red.withOpacity(0.1),
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
