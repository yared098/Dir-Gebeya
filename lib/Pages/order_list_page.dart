import 'package:dirgebeya/Pages/order_detail_page.dart';
import 'package:flutter/material.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  String selectedStatus = 'All';

  final List<Map<String, dynamic>> mockOrders = [
    {
      'orderId': '#001',
      'customer': 'John Doe',
      'total': 150.0,
      'status': 'Delivered',
      'payment': 'Cash',
      'date': '2025-07-05 09:15 AM',
    },
    {
      'orderId': '#002',
      'customer': 'Sara Smith',
      'total': 80.0,
      'status': 'Pending',
      'payment': 'Cash on Delivery',
      'date': '2025-07-04 11:30 AM',
    },
    {
      'orderId': '#003',
      'customer': 'Mike Johnson',
      'total': 320.0,
      'status': 'Packing',
      'payment': 'CashOnBy Wallet',
      'date': '2025-07-03 01:00 PM',
    },
    {
      'orderId': '#004',
      'customer': 'Linda Ray',
      'total': 200.0,
      'status': 'Rejected',
      'payment': 'Cash on Delivery',
      'date': '2025-07-02 03:45 PM',
    },
  ];

  final List<String> statusFilters = [
    'All',
    'Pending',
    'Packing',
    'Delivered',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = selectedStatus == 'All'
        ? mockOrders
        : mockOrders
              .where((order) => order['status'] == selectedStatus)
              .toList();

    return Scaffold(
      body: Column(
        children: [
          /// 🔘 Filter Buttons
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // rounded corners
              side: BorderSide(
                color: const Color.fromARGB(255, 253, 253, 253),
                width: 1.5,
              ), // blue border
            ),
            child: SizedBox(
              height:
                  40, // 10 px is very small for a header, so 50 px looks better
              child: Center(
                child: Text(
                  "My Orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters[index];
                final isSelected = status == selectedStatus;

                // For "All" selected, use a stronger blue background
                final chipSelectedColor = (status == 'All' && isSelected)
                    ? const Color.fromARGB(255, 20, 70, 110) // strong blue for "All"
                    : Colors.blue.shade100; // lighter blue for others

                final chipLabelColor = isSelected
                    ? Colors.white
                    : Colors.black87;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedStatus = status),
                    selectedColor: chipSelectedColor,
                    labelStyle: TextStyle(
                      color: chipLabelColor,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          /// 🧾 Orders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(context, order);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    Color statusColor;
    switch (order['status']) {
      case 'Delivered':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Packing':
        statusColor = Colors.blue;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color paymentColor;
    switch (order['payment'].toString().toLowerCase()) {
      case 'cash':
        paymentColor = Colors.green.shade300;
        break;
      case 'cash on delivery':
        paymentColor = Colors.orange.shade300;
        break;
      case 'cashonby wallet':
        paymentColor = Colors.blue.shade300;
        break;
      default:
        paymentColor = Colors.grey.shade300;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID & Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['orderId'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 21, 49, 99),

                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "ETB ${order['total']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Date Row only
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order['date'],
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // New Row: Status and Payment side by side
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Spread to edges
                children: [
                  // Status Tag (left)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),

                  // Payment Tag (right)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: paymentColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.payment,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order['payment'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
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
      ),
    );
  }
}
