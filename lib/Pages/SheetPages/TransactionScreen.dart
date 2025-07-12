import 'dart:ui';

import 'package:dirgebeya/Model/TransactionModel.dart';
import 'package:dirgebeya/Provider/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Denied'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loadProvider = Provider.of<LoanProvider>(context, listen: false);
      loadProvider.fetchLoans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (context, loadProvider, _) {
        final isLoading = loadProvider.isLoading;
        final error = loadProvider.error;
        final allLoans = loadProvider.loans;

        String selectedStatus = _filters[_selectedFilterIndex].toLowerCase();
        final filteredLoans = selectedStatus == 'all'
            ? allLoans
            : allLoans.where((loan) => loan.status.toLowerCase() == selectedStatus).toList();

        final transactions = _mapLoansToTransactions(filteredLoans);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Transactions',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildFilterChips(),
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Expanded(
                  child: Center(child: Text('Error: $error')),
                )
              else if (transactions.isEmpty)
                const Expanded(
                  child: Center(child: Text('No transactions found')),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return TransactionCard(transaction: transactions[index]);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Filter chips UI
  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedFilterIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(_filters[index]),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  }
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.transparent),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Convert Loan to Transaction
  List<Transaction> _mapLoansToTransactions(List loans) {
    return loans.map<Transaction>((loan) {
      TransactionStatus status;
      switch (loan.status.toLowerCase()) {
        case 'approved':
          status = TransactionStatus.Approved;
          break;
        case 'denied':
          status = TransactionStatus.Denied;
          break;
        case 'pending':
        default:
          status = TransactionStatus.Pending;
          break;
      }

      return Transaction(
        id: loan.loanId.toString(),
        date: loan.dueDate,
        amount: loan.amount,
        status: status,
      );
    }).toList();
  }
}

// --- Transaction Card UI (unchanged) ---
class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction# ${transaction.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${transaction.amount}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              transaction.date,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            _buildStatusWidget(transaction.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(TransactionStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case TransactionStatus.Denied:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'Denied';
        break;
      case TransactionStatus.Approved:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Approved';
        break;
      case TransactionStatus.Pending:
        color = const Color(0xFF1D4ED8);
        icon = Icons.history;
        text = 'Pending';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
