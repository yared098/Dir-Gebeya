import 'package:dirgebeya/Model/Transaction.dart';
import 'package:dirgebeya/Provider/TransactionProvider.dart' hide TransactionStatus;
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text("Error: ${provider.error}"));
          }

          if (provider.transactions.isEmpty) {
            return const Center(child: Text("No transactions available."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: provider.transactions.length,
            itemBuilder: (context, index) {
              final tx = provider.transactions[index];
              return _transactionCard(tx);
            },
          );
        },
      ),
    );
  }

  Widget _transactionCard(Transaction tx) {
  final Color statusColor = _statusColor(tx.status);
  final IconData statusIcon = _statusIcon(tx.status);

  return Card(
    elevation: 1,
    color: Colors.white,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: ID & amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction# ${tx.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tx.amount.toStringAsFixed(2)} ETB',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Date row
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                tx.date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Row
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 6),
              Text(
                tx.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Penalty
          if (tx.penalty != null)
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  "Penalty: ${tx.penalty!.toStringAsFixed(2)} ETB",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          // Optional Comment
          if (tx.comment != null && tx.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Comment: ${tx.comment}",
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return Colors.green;
    case 'due':
      return Colors.orange;
    case 'upcoming':
    case 'upcaming': // in case of a typo
      return Colors.blueGrey;
    case 'failed':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}


IconData _statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return Icons.check_circle_outline;
    case 'due':
      return Icons.error_outline;
    case 'upcoming':
    case 'upcaming': // fallback typo
      return Icons.access_time;
    default:
      return Icons.info_outline;
  }
}

}
