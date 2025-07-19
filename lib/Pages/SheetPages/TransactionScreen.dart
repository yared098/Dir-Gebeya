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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: Colors.deepPurple.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ID and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaction ID: ${tx.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.deepPurple,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(tx.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tx.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(tx.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),

            // Amount
            Text(
              "Amount: \$${tx.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  tx.date,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Penalty if exists
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
        return Colors.redAccent;
      case 'upcaming':
      case 'upcoming': // just in case
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
