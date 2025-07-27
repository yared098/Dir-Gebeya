import 'dart:ui';
import 'package:dirgebeya/Model/TransactionModel.dart';
import 'package:dirgebeya/Provider/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Paid', 'Unpaid', 'Due'];

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<LoanProvider>(
      builder: (context, loadProvider, _) {
        final isLoading = loadProvider.isLoading;
        final error = loadProvider.error;
        final allLoans = loadProvider.loans;

        final selectedStatus = _filters[_selectedFilterIndex].toLowerCase();
        final mappedTransactions = _mapLoansToTransactions(allLoans);

        final filteredTransactions = selectedStatus == 'all'
            ? mappedTransactions
            : mappedTransactions.where((tx) {
                final statusString = tx.status.toString().split('.').last.toLowerCase();
                return statusString == selectedStatus;
              }).toList();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Loans',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
       body: RefreshIndicator(
  onRefresh: () async {
    await Provider.of<LoanProvider>(context, listen: false).fetchLoans();
  },
  child: isLoading
      ?  ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        )
      : error != null
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 400,
                  child: Center(child: Text('Error: $error')),
                ),
              ],
            )
          : filteredTransactions.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 400,
                      child: Center(child: Text('No transactions found')),
                    ),
                  ],
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildFilterChips(context),
                    const SizedBox(height: 8),
                    ...filteredTransactions.map((tx) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                        child: TransactionCard(transaction: tx),
                      );
                    }).toList(),
                  ],
                ),
),

        );
      },
    );
  }

  /// Filter chips UI
 Widget _buildFilterChips(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
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
                  if (selected) setState(() => _selectedFilterIndex = index);
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: theme.primaryColor,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.transparent),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            );
          },
        ),
      ),
    );
  }
  /// Convert Loan to Transaction with computed status
  List<Transaction> _mapLoansToTransactions(List loans) {
    return loans.map<Transaction>((loan) {
      DateTime dueDate = DateTime.tryParse(loan.dueDate) ?? DateTime.now();
      DateTime now = DateTime.now();
      int daysSinceDue = now.difference(dueDate).inDays;

      TransactionStatus status;
      if (loan.status.toLowerCase() == 'paid') {
        status = TransactionStatus.Paid;
      } else if (daysSinceDue >= 20) {
        status = TransactionStatus.Due;
      } else {
        status = TransactionStatus.Upcaming;
      }

    
      return Transaction(
        id: loan.loanId.toString(),
        date: loan.dueDate,
        amount: loan.amount,
        status: status,
        penalty: status == TransactionStatus.Due ? loan.penalty : null,
      );
    }).toList();
  }
}

// --- Transaction Card UI ---
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
            // Top row: ID + amount
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            if (transaction.status == TransactionStatus.Due &&
                transaction.penalty != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.money_off,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Penalty: ${transaction.penalty} ETB',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
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
      case TransactionStatus.All:
        color = Colors.red;
        icon = Icons.cancel;
        text = 'All';
        break;
      case TransactionStatus.Paid:
        color = Colors.green;
        icon = Icons.check_circle;
        text = 'Paid';
        break;
      case TransactionStatus.Upcaming:
        color = const Color(0xFF1D4ED8);
        icon = Icons.history;
        text = 'Upcoming';
        break;
      case TransactionStatus.Due:
        color = Colors.redAccent;
        icon = Icons.warning;
        text = 'Due';
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
