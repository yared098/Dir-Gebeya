import 'package:dirgebeya/Model/Transaction.dart';
import 'package:dirgebeya/Provider/TransactionProvider.dart' hide TransactionStatus;
import 'package:dirgebeya/Widgets/_providerErroeMessage.dart';
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
    // Initial fetch without forceRefresh
    Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
  }

  Future<void> _refresh() async {
    // Force fetch new data
    await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactionss"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            // Show loading indicator only if loading and no data yet
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return ProviderErrorWidget(
            message:"No transactions available"
          );
          }

          if (provider.transactions.isEmpty) {
            return const Center(child: Text("No transactions available."));
          }

          // Wrap the ListView in RefreshIndicator
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions[index];
                return _transactionCard(tx);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _transactionCard(Transaction tx) {
    final Color statusColor = _statusColor(tx.status);
    final IconData statusIcon = _statusIcon(tx.status);
    final statusText = _mapStatusCodeToText(tx.status);

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
                  statusText.toUpperCase(),
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

  String _mapStatusCodeToText(String statusCode) {
    switch (statusCode) {
      case '0':
        return "Waiting For Payment";
      case '1':
        return "Complete";
      case '2':
        return "Total not match";
      case '3':
        return "Denied";
      case '4':
        return "Expired";
      case '5':
        return "Failed";
      case '6':
        return "Pending";
      case '7':
        return "Processed";
      case '8':
        return "Refunded";
      case '9':
        return "Reversed";
      case '10':
        return "Voided";
      case '11':
        return "Canceled Reversal";
      case '12':
        return "Waiting For Payment";
      default:
        return "Unknown";
    }
  }

  IconData _statusIcon(String statusCode) {
    switch (statusCode) {
      case '1': // Complete
        return Icons.check_circle_outline;
      case '2': // Total not match
        return Icons.error_outline;
      case '3': // Denied
        return Icons.block;
      case '4': // Expired
        return Icons.hourglass_disabled;
      case '0': // Waiting for payment
        return Icons.hourglass_bottom;
      case '5': // Failed
        return Icons.cancel_outlined;
      case '6': // Pending
        return Icons.pending_actions;
      case '7': // Processed
        return Icons.sync;
      case '8': // Refunded
        return Icons.reply;
      default:
        return Icons.info_outline;
    }
  }

  Color _statusColor(String statusCode) {
    switch (statusCode) {
      case '1': // Complete
        return Colors.green.shade700;
      case '2': // Total not match
        return Colors.orange.shade700;
      case '3': // Denied
        return Colors.red.shade700;
      case '4': // Expired
        return Colors.grey.shade600;
      case '0': // Waiting for payment
        return Colors.blue.shade700;
      case '5': // Failed
        return Colors.redAccent;
      case '6': // Pending
        return Colors.blueGrey;
      case '7': // Processed
        return Colors.teal;
      case '8': // Refunded
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
