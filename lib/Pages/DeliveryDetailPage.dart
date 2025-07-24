import 'package:dirgebeya/Pages/Widgets/showStatusDialog.dart';
import 'package:dirgebeya/Provider/order_detail_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:dirgebeya/Provider/dispatch_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DispatchDetailPage extends StatefulWidget {
  final int orderId;

  const DispatchDetailPage({super.key, required this.orderId});

  @override
  State<DispatchDetailPage> createState() => _DispatchDetailPageState();
}

class _DispatchDetailPageState extends State<DispatchDetailPage> {
  @override
  void initState() {
    super.initState();

    // Trigger fetchOrderDetail when the page is opened
    Future.microtask(() {
      final provider = Provider.of<OrderDetailProvider>(context, listen: false);
      provider.fetchOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderDetailProvider>(context);
    final order = provider.order;
    final products = provider.products;
    final history = provider.history;

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.error != null) {
      return Scaffold(body: Center(child: Text(provider.error!)));
    }

    return Scaffold(
      appBar: _buildAppBar(context, order),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (order != null) _buildCustomerInfoCard(order,products[0]),
            const SizedBox(height: 16),
             if (order != null) _buildBillingCard(order),
             const SizedBox(height: 16),
             _buildReasonCard(history),
            if (products.isNotEmpty && order != null)
              _buildProductCard(products[0], order),
            const SizedBox(height: 16),
            
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(context,order,products)
    );
  }

  AppBar _buildAppBar(BuildContext context, Order? order) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Delivery Task ${order?.id ?? ''}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            order?.createdAt ?? '',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(

            backgroundColor: AppColors.primary,
            child: const Icon(Icons.history, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(OrderProduct product, Order order) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Image.network(
                product.productImage,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.productPrice.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.paymentMethod,
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.payment, color: Colors.orange, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        order.paymentMethod,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonCard(List<OrderHistory> history) {
    final dateFormat = DateFormat(
      'yyyy-MM-dd • hh:mm a',
    ); // Customize as needed

    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.indeterminate_check_box_outlined,
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (history.isEmpty)
              const Text(
                'No reason history found.',
                style: TextStyle(color: Colors.black54),
              )
            else
              ...history.expand(
                (item) => [
                  ListTile(
                    // leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(
                      item.historyType ?? 'Unknown Type',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      item.comment ?? 'No additional info',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: Text(
                      item.date != null
                          ? dateFormat.format(
                              DateTime.tryParse(item.date!) ?? DateTime.now(),
                            )
                          : '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                    height: 1,
                    color: Color.fromARGB(255, 170, 161, 161),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingCard(Order order) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBillingRow(
              'Product Tax',
              '+ ${order.taxCost.toStringAsFixed(2)} ETB',
            ),
            _buildBillingRow(
              'Sub Total',
              '${order.total.toStringAsFixed(2)} ETB',
            ),
            const Divider(height: 24),
            _buildBillingRow(
              'Total Receivable Amount',
              '${order.total.toStringAsFixed(2)} ETB',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildBillingRow(String label, String amount, {bool isTotal = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isTotal ? Colors.black : Colors.grey[700],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 13 : 12,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: isTotal ? Color(0xFF1D4ED8) : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ],
        ),
        if (isTotal)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Collect this amount if payment term is Cash on Delivery.",
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

  Widget _buildCustomerInfoCard(Order order, OrderProduct product) {
    return Card(
     elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Delivery Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Profile Info + Call Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    product.profile != null && product.profile!.isNotEmpty
                        ? CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(product.profile!),
                          )
                        : const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),

                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${order.address}, ${order.city}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                    launchUrl(Uri.parse('tel:${order.phone}'));
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Start - End Destination with connector
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vertical icon column with dots
                Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                    const Icon(Icons.map, color: Colors.blue),
                  ],
                ),
                const SizedBox(width: 12),
                // Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Start Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'My Address',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'End Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.address ?? 'Not provided',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


Widget _buildActionButtons(BuildContext context, Order? order, List<OrderProduct> products) {
  final provider = Provider.of<OrderDetailProvider>(context, listen: false);

  return Container(
    // margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(16),
    
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, size: 20),
        label: const Text(
          'Finish',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (ctx) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.check, color: Colors.green),
                      title: const Text('Approve'),
                      onTap: () async {
                        Navigator.pop(ctx);
                        if (order != null) {
                          final success = await provider.approveOrder(order.id);
                          if (success) {
                            showStatusDialog(context, isAccepted: true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.error ?? "Approval failed")),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.close, color: Colors.red),
                      title: const Text('Reject'),
                      onTap: () {
                        Navigator.pop(ctx);
                        showStatusDialog(context, isAccepted: false);
                        // TODO: Add reject logic here
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ),
  );
}

}
