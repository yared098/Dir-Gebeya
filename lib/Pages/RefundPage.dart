// --- REFUND SCREEN WIDGET ---
import 'dart:ui';

import 'package:dirgebeya/Model/RefundStatus.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
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
  final List<RefundRequest> _allRefunds = [
    // Pending
    RefundRequest(
      orderId: '100134',
      productName: 'Leather Ladies Bag',
      imageUrl: 'https://i.imgur.com/gKDC2tC.png',
      price: 15.00,
      reason: 'There are many variations of passages of Lorem...',
      date: DateTime(2022, 10, 11, 23, 12),
      status: RefundStatus.Pending,
    ),
    // Approved
    RefundRequest(
      orderId: '100125',
      productName: 'Modern Wrist Watch',
      imageUrl: 'https://i.imgur.com/sI3Jm2z.png',
      price: 45.50,
      reason: 'Approved for full refund due to defect.',
      date: DateTime(2022, 10, 10, 14, 30),
      status: RefundStatus.Approved,
    ),
    RefundRequest(
      orderId: '100121',
      productName: 'Bluetooth Speaker',
      imageUrl: 'https://i.imgur.com/v1nysjB.png',
      price: 89.99,
      reason: 'Customer request approved.',
      date: DateTime(2022, 10, 9, 11, 00),
      status: RefundStatus.Approved,
    ),
  ];

  // Gets the filtered list based on the selected status
  List<RefundRequest> get _filteredList {
    return _allRefunds.where((r) => r.status == _selectedStatus).toList();
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
                                padding:
                                     EdgeInsets.only(bottom: 8.0, left: 4.0),
                                // child: Text(
                                //   DateFormat('dd-MMM-yyyy hh:mm a').format(request.date),
                                //   style: const TextStyle(color: Colors.grey, fontSize: 14),
                                // ),
                              ),
                              RefundCard(request: request),
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
                color: _selectedStatus == status ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildEmptyState() {
      return Center(
        key: ValueKey<RefundStatus>(_selectedStatus), // Ensure switcher recognizes change
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
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${request.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          request.status.name,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600),
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
                          fontWeight: FontWeight.bold),
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