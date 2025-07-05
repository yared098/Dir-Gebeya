import 'package:flutter/material.dart';

class RefundPage extends StatefulWidget {
  const RefundPage({super.key});

  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  String selectedStatus = 'All';

  final List<String> statusFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Refunded',
  ];

  final List<Map<String, dynamic>> mockRefunds = [
    {
      'refundId': 'R001',
      'status': 'Pending',
      'amount': 50.0,
      'reason': 'Damaged item',
      'date': '2025-07-03',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'refundId': 'R002',
      'status': 'Approved',
      'amount': 100.0,
      'reason': 'Late delivery',
      'date': '2025-07-01',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'refundId': 'R003',
      'status': 'Rejected',
      'amount': 80.0,
      'reason': 'No valid reason',
      'date': '2025-06-28',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
    {
      'refundId': 'R004',
      'status': 'Refunded',
      'amount': 40.0,
      'reason': 'Wrong product',
      'date': '2025-06-25',
      'imageUrl': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkB4CEjRkLRzwcydd137vmel61jC_hs3wQpA&s',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      case 'Refunded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRefunds = selectedStatus == 'All'
        ? mockRefunds
        : mockRefunds.where((refund) => refund['status'] == selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Requests'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// 🔘 Filter Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters[index];
                final isSelected = selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedStatus = status),
                    selectedColor: Colors.blue.shade100,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          /// 📄 Refunds List
          Expanded(
            child: filteredRefunds.isEmpty
                ? const Center(child: Text("No refund requests"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRefunds.length,
                    itemBuilder: (context, index) {
                      final refund = filteredRefunds[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 👤 Row with Image + Refund Info
                              Row(
                                children: [
                                  /// 🖼️ Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      refund['imageUrl'],
                                      width: 100,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  /// 🔤 Column with ID, Status, Price
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          refund['refundId'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(refund['status']).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            refund['status'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _getStatusColor(refund['status']),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "ETB ${refund['amount']}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),

                              const SizedBox(height: 12),

                              /// 📅 Date
                              Text("Date: ${refund['date']}", style: const TextStyle(color: Colors.black54)),

                              const SizedBox(height: 10),

                              /// 📝 Reason section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Reason: ${refund['reason']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
