import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<Map<String, dynamic>> allTransactions = [
    {
      'txn': '#TXN001',
      'amount': 500,
      'status': 'Approved',
      'datetime': '2025-07-04 11:23 AM',
    },
    {
      'txn': '#TXN002',
      'amount': 100,
      'status': 'Denied',
      'datetime': '2025-07-03 02:15 PM',
    },
    {
      'txn': '#TXN003',
      'amount': 350,
      'status': 'Pending',
      'datetime': '2025-07-02 06:45 PM',
    },
    {
      'txn': '#TXN004',
      'amount': 275,
      'status': 'Approved',
      'datetime': '2025-07-01 09:10 AM',
    },
    {
      'txn': '#TXN005',
      'amount': 150,
      'status': 'Pending',
      'datetime': '2025-07-01 03:30 PM',
    },
  ];

  final List<String> filters = ['All', 'Pending', 'Approved', 'Denied'];
  String selectedFilter = 'All';

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == 'All') return allTransactions;
    return allTransactions.where((tx) => tx['status'] == selectedFilter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Denied':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check_circle;
      case 'Denied':
        return Icons.cancel;
      case 'Pending':
        return Icons.hourglass_top;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Filter List
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('No transactions found.'))
                  : ListView.separated(
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        final color = _statusColor(tx['status']);
                        final icon = _statusIcon(tx['status']);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(icon, color: color, size: 30),
                            title: Text(tx['txn'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(tx['datetime']),
                            trailing: Text(
                              'ETB ${tx['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
