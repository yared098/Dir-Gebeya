import 'package:dirgebeya/Provider/order_provider.dart.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'order_detail_page.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Pending', 'Packaging', 'Delivered'];

  @override
  void initState() {
    super.initState();
    // Fetch orders once on screen load
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  // Convert provider Order model to UI Order model
  List<Order> _mapProviderOrdersToUI(List<Order> providerOrders) {
    return providerOrders
        .map(
          (o) => Order(
            tax: 2.0,
            orderId: 1,
            id: o.orderId?.toString() ?? '',
            date: o.date ?? '',
            amount: o.amount ?? 0,
            status: o.status?.toUpperCase() ?? '',
            paymentMode: o.paymentMode ?? '',
          ),
        )
        .toList();
  }

  List<Order> _filteredOrders(List<Order> orders) {
    final selected = _filters[_selectedFilterIndex].toUpperCase();
    if (selected == 'ALL') return orders;
    return orders.where((order) => order.status == selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, child) {
            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orderProvider.error != null) {
              return Center(child: Text(orderProvider.error!));
            }

            final orders = _mapProviderOrdersToUI(orderProvider.orders);
            final filteredOrders = _filteredOrders(orders);

            return Column(
              children: [
                _buildAppBar(context),
                _buildFilterChips(),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(child: Text("No orders found."))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsScreen(
                                    orderId: filteredOrders[index].orderId,
                                  ),
                                ),
                              ),
                              child: OrderCard(order: filteredOrders[index]),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ClipPath(
            // If you have a custom shape, keep this enabled:
            // clipper: HexagonClipper(),
            child: Container(
              width: 40,
              height: 45,

              child: Padding(
                padding: const EdgeInsets.all(6.0), // Adjust padding as needed
                child: Image.asset(
                  'assets/image/logo.png', // ✅ Your logo path
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'My Order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_filters[index]),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilterIndex = index);
              },
              labelStyle: TextStyle(
  color: isSelected ? Colors.white : Theme.of(context).primaryColor,
  fontWeight: FontWeight.w600,
),

              selectedColor: AppColors.primary,
              backgroundColor: const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusDetails = _getStatusDetails(order.status);
    final paymentDetails = _getPaymentDetails(order.paymentMode);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order# ${order.orderId}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  '\$${order.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.date, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusDetails['icon'],
                      color: statusDetails['color'],
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusDetails['text'],
                      style: TextStyle(color: statusDetails['color']),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      paymentDetails['text'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      paymentDetails['icon'],
                      color: paymentDetails['color'],
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return {
          'text': 'Delivered',
          'icon': Icons.check_circle,
          'color': Colors.green,
        };
      case "PENDING":
        return {
          'text': 'Pending',
          'icon': Icons.pending_actions,
          'color': Colors.orange,
        };
      case "PACKAGING":
        return {
          'text': 'Packaging',
          'icon': Icons.all_inbox,
          'color': Colors.teal,
        };
      case "ACCEPTED":
        return {
          'text': 'Accepted',
          'icon': Icons.local_shipping,
          'color': Colors.blue,
        };
      case "CANCELLED":
        return {'text': 'Cancelled', 'icon': Icons.cancel, 'color': Colors.red};
      default:
        return {
          'text': 'Unknown',
          'icon': Icons.help_outline,
          'color': Colors.grey,
        };
    }
  }

  Map<String, dynamic> _getPaymentDetails(String method) {
    switch (method.toLowerCase()) {
      case "cash":
        return {
          'text': 'Cash On Delivery',
          'icon': Icons.money,
          'color': Colors.green,
        };
      case "wallet":
        return {
          'text': 'Wallet',
          'icon': Icons.account_balance_wallet,
          'color': Colors.blue,
        };
      default:
        return {'text': 'Other', 'icon': Icons.payment, 'color': Colors.grey};
    }
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
