import 'package:dirgebeya/Provider/order_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
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

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(child: Text(provider.error!)),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, order),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (products.isNotEmpty) _buildProductCard(products[0], order),
            const SizedBox(height: 16),
            _buildReasonCard(),
            const SizedBox(height: 16),
            if (order != null) _buildBillingCard(order),
            const SizedBox(height: 16),
            if (order != null) _buildCustomerInfoCard(order),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(context),
    );
  }
AppBar _buildAppBar(BuildContext context, OrderDetail? order) {
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
          'Order# ${order?.id ?? ''}',
          style: const TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold),
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
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.history, color: Colors.white, size: 24),
        ),
      ),
    ],
  );
}

Widget _buildProductCard(OrderProduct product, OrderDetail? order) {
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
              product.image,
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
                  product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order?.paymentMethod ?? 'Pending',
                    style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payment, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text(order?.paymentMethod ?? 'N/A',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildReasonCard() {
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
                Icon(Icons.monetization_on, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Text('Reason',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don\'t look even slightly believable.',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAttachmentChip('MP3', Icons.music_note,
                    const Color(0xFFEEF2FF), const Color(0xFF4338CA)),
                const SizedBox(width: 12),
                _buildAttachmentChip('Sheet', Icons.grid_on,
                    const Color(0xFFF0FDF4), const Color(0xFF166534)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(
      String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration:
                BoxDecoration(color: bgColor, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
Widget _buildBillingCard(OrderDetail order) {
  return Card(
    elevation: 1,
    color: Colors.white,
    shadowColor: Colors.black.withOpacity(0.05),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildBillingRow('Product Tax', '+ \$${order.tax.toStringAsFixed(2)}'),
          _buildBillingRow('Sub Total', '\$${order.total.toStringAsFixed(2)}'),
          const Divider(height: 24),
          _buildBillingRow('Total Refundable Amount', '\$${order.total.toStringAsFixed(2)}',
              isTotal: true),
        ],
      ),
    ),
  );
}


  Widget _buildBillingRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black87 : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? const Color(0xFF1D4ED8) : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildCustomerInfoCard(OrderDetail order) {
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
              Icon(Icons.person, color: Colors.grey, size: 24),
              SizedBox(width: 8),
              Text('Customer Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage('https://i.imgur.com/kQDt90n.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.phone,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  Text('${order.address}, ${order.city}',
                      style: const TextStyle(color: Colors.black54)),
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}


  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}