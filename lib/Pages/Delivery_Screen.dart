import 'dart:ui';
import 'package:dirgebeya/Model/Order.dart';
import 'package:dirgebeya/Model/RefundStatus.dart';
import 'package:dirgebeya/Pages/DeliveryDetailPage.dart';
import 'package:dirgebeya/Provider/dispatch_provider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Refund Screen ---
class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  RefundStatus _selectedStatus = RefundStatus.Assigned;

  List<Dispatch> get _allDispatches {
    final provider = Provider.of<DispatchProvider>(context);
    if (provider.error != null || provider.isLoading) return [];
    return provider.dispatches;
  }

  List<Dispatch> get _filteredList {
    return _allDispatches.where((d) {
      return d.status.toLowerCase() == _selectedStatus.name.toLowerCase();
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DispatchProvider>(
        context,
        listen: false,
      ).fetchDispatches(status: _selectedStatus.name.toLowerCase());
    });
  }

  void _onStatusSelected(RefundStatus status) {
    setState(() {
      _selectedStatus = status;
    });
    Provider.of<DispatchProvider>(
      context,
      listen: false,
    ).fetchDispatches(status: status.name.toLowerCase());
  }

  final List<RefundStatus> _chipOrder = [
    RefundStatus.Assigned,
    RefundStatus.Accepted,
    RefundStatus.Picked,
    RefundStatus.Delivered,
    RefundStatus.Rejected,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            _buildAppBar(context),
            _buildFilterChips(),
            // Expanded(
            //   child: AnimatedSwitcher(
            //     duration: const Duration(milliseconds: 400),
            //     transitionBuilder: (child, animation) =>
            //         FadeTransition(opacity: animation, child: child),
            //     child: _filteredList.isEmpty
            //         ? _buildEmptyState()
            //         : ListView.builder(
            //             key: ValueKey<RefundStatus>(_selectedStatus),
            //             padding: const EdgeInsets.all(16.0),
            //             itemCount: _filteredList.length,
            //             itemBuilder: (context, index) {
            //               final dispatch = _filteredList[index];
            //               return Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   const SizedBox(height: 8),
            //                   DispatchCard(dispatch: dispatch),
            //                   const SizedBox(height: 16),
            //                 ],
            //               );
            //             },
            //           ),
            //   ),
            // ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<DispatchProvider>(
                    context,
                    listen: false,
                  ).fetchDispatches(status: _selectedStatus.name.toLowerCase());
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _filteredList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          key: ValueKey<RefundStatus>(_selectedStatus),
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _filteredList.length,
                          itemBuilder: (context, index) {
                            final dispatch = _filteredList[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                DispatchCard(dispatch: dispatch),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
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
            child: Container(
              width: 40,
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/image/logo.png',
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
        children: _chipOrder.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status.label),
              selected: _selectedStatus == status,
              onSelected: (selected) {
                if (selected) _onStatusSelected(status);
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
      key: ValueKey<RefundStatus>(_selectedStatus),
      child: Text(
        'No ${_selectedStatus.label.toLowerCase()} requests found.',
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

// --- Status Extension ---
extension RefundStatusLabel on RefundStatus {
  String get label {
    switch (this) {
      case RefundStatus.Assigned:
        return "Assigned";
      case RefundStatus.Accepted:
        return "Accepted";
      case RefundStatus.Picked:
        return "Picked Up";
      case RefundStatus.Delivered:
        return "Delivered";
      case RefundStatus.Rejected:
        return "Rejected";
    }
  }
}

// --- Dispatch Card (Unchanged except for status mapping updates) ---
class DispatchCard extends StatelessWidget {
  final Dispatch dispatch;
  const DispatchCard({super.key, required this.dispatch});

  @override
  Widget build(BuildContext context) {
    final statusDetails = _getStatusDetails(dispatch.status ?? '');
    final paymentDetails = _getPaymentDetails(
      dispatch.pickupTime?.toString() ?? '',
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DispatchDetailPage(
              orderId: dispatch.id,
              Status: dispatch.status,
            ),
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
                dispatch.assignedTime?.toString() ?? '',
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
      case "ASSIGNED":
        return {'icon': Icons.assignment_turned_in, 'color': Colors.blueAccent};
      case "DELIVERED":
        return {'icon': Icons.check_circle, 'color': Colors.green};
      case "PICKEDUP":
        return {'icon': Icons.local_shipping, 'color': Colors.indigo};
      case "ACCEPTED":
        return {'icon': Icons.thumb_up, 'color': Colors.blue};
      case "REJECTED":
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
