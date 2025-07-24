// --- REFUND SCREEN WIDGET ---
import 'dart:ui';

import 'package:dirgebeya/Model/Order.dart';
import 'package:dirgebeya/Model/RefundStatus.dart';
import 'package:dirgebeya/Pages/DeliveryDetailPage.dart';
import 'package:dirgebeya/Provider/dispatch_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  // The currently selected filter status
  RefundStatus _selectedStatus = RefundStatus.Pending;

  // Dummy data for all refund statuses to demonstrate filtering
  List<Dispatch> get _allDispatches {
    final provider = Provider.of<DispatchProvider>(context);
    if (provider.error != null || provider.isLoading) return [];
    return provider.dispatches;
  }

  // Gets the filtered list based on the selected status
  List<Dispatch> get _filteredList {
    return _allDispatches.where((d) {
      return d.status.toLowerCase() == _selectedStatus.name.toLowerCase();
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Fetch dispatch data with initial date range
    Future.microtask(() {
      Provider.of<DispatchProvider>(
        context,
        listen: false,
      ).fetchDispatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: _buildAppBar(context),
        body: Column(
          children: [
            _buildAppBar(context),
            _buildFilterChips(),
            Expanded(
              // This widget handles the smooth transition between lists
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  // Fade transition for a smooth effect
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _filteredList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        // IMPORTANT: The key tells AnimatedSwitcher that the child has changed
                        key: ValueKey<RefundStatus>(_selectedStatus),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredList.length,
                        itemBuilder: (context, index) {
                          final request = _filteredList[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: 8.0,
                                  left: 4.0,
                                ),
                              ),
                              DispatchCard(dispatch: _filteredList[index]),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
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
              'Delivery Tasks',
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
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: RefundStatus.values.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status.name),
              selected: _selectedStatus == status,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedStatus = status;
                  });
                }
              },
              labelStyle: TextStyle(
                color: _selectedStatus == status
                    ? Colors.white
                    : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: ValueKey<RefundStatus>(
        _selectedStatus,
      ), // Ensure switcher recognizes change
      child: Text(
        'No ${_selectedStatus.name.toLowerCase()} requests found.',
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

// --- REUSABLE REFUND CARD WIDGET ---
class RefundCard extends StatelessWidget {
  final RefundRequest request;
  const RefundCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order# ${request.orderId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Image.network(request.imageUrl, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${request.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
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
                          request.status.name,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Reason: ',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: request.reason),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HEXAGON CLIPPER FOR THE LOGO ---
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

class DispatchCard extends StatelessWidget {
  final Dispatch dispatch;
  const DispatchCard({super.key, required this.dispatch});

  @override
  Widget build(BuildContext context) {
    final statusDetails = _getStatusDetails(dispatch.status ?? '');
    final paymentDetails = _getPaymentDetails(dispatch.pickupTime ?? '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DispatchDetailPage(orderId: dispatch.id),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order# ${dispatch.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(Icons.info_outline, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dispatch.assignedTime ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Status & Payment Row
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
                        dispatch.status ?? 'Unknown',
                        style: TextStyle(
                          color: statusDetails['color'],
                          fontWeight: FontWeight.w500,
                        ),
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
              const SizedBox(height: 10),
              Text(
                'Driver ID: ${dispatch.driverId ?? 'N/A'}',
                style: const TextStyle(color: Colors.black87),
              ),
              if ((dispatch.remarks ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Remarks: ${dispatch.remarks}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusDetails(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return {'icon': Icons.check_circle, 'color': Colors.green};
      case "PENDING":
        return {'icon': Icons.pending_actions, 'color': Colors.orange};
      case "PACKAGING":
        return {'icon': Icons.all_inbox, 'color': Colors.teal};
      case "ACCEPTED":
        return {'icon': Icons.local_shipping, 'color': Colors.blue};
      case "CANCELLED":
        return {'icon': Icons.cancel, 'color': Colors.red};
      default:
        return {'icon': Icons.help_outline, 'color': Colors.grey};
    }
  }

  Map<String, dynamic> _getPaymentDetails(String method) {
    switch (method.toLowerCase()) {
      case "cash":
      case "cash on delivery":
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
