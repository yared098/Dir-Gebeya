// --- REFUND SCREEN WIDGET ---
import 'dart:ui';

import 'package:dirgebeya/Model/RefundStatus.dart';
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
      ).fetchDispatches(dateFrom: '2025-06-03', dateTo: '2025-06-06');
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
    return GestureDetector(
      onTap: () {
        _showUpdateBottomSheet(context, dispatch);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order# ${dispatch.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Icon(Icons.info_outline), // Info icon to hint tap
                ],
              ),
              const SizedBox(height: 8),
              Text('Status: ${dispatch.status}', style: const TextStyle(color: Colors.black87)),
              Text('Driver ID: ${dispatch.driverId}', style: const TextStyle(color: Colors.grey)),
              Text('Assigned: ${dispatch.assignedTime}', style: const TextStyle(color: Colors.grey)),
              if (dispatch.remarks.isNotEmpty)
                Text('Remarks: ${dispatch.remarks}', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateBottomSheet(BuildContext context, Dispatch dispatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _UpdateDispatchForm(dispatch: dispatch);
      },
    );
  }
}

class _UpdateDispatchForm extends StatefulWidget {
  final Dispatch dispatch;
  const _UpdateDispatchForm({required this.dispatch});

  @override
  State<_UpdateDispatchForm> createState() => _UpdateDispatchFormState();
}

class _UpdateDispatchFormState extends State<_UpdateDispatchForm> {
  late String _selectedStatus;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.dispatch.status;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DispatchProvider>(context, listen: false);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: bottomInset + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Text(
                'Update Order #${widget.dispatch.orderId}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['approved', 'rejected', 'pending']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status[0].toUpperCase() + status.substring(1)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Update Status",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: "Comment",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now().toIso8601String();
                  final success = await provider.updateDispatchStatus(
                    orderId: widget.dispatch.orderId,
                    status: _selectedStatus,
                    time: now,
                    comment: _commentController.text.trim(),
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Status updated successfully")),
                    );
                    provider.fetchDispatches(dateFrom: '2025-06-03', dateTo: '2025-06-06');
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Update"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
