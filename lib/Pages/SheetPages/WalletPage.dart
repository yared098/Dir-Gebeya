import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/wallet_provider.dart'; // adjust import if needed
import '../SheetPages/WithdrawalForm.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = Provider.of<WalletProvider>(
        context,
        listen: false,
      );
      walletProvider.fetchSummary();
      walletProvider.fetchTransactions();
    });
  }

  void _showWithdrawalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const WithdrawalForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        final summary = walletProvider.summary;
        final transactions = walletProvider.transactions;
        final isLoading = walletProvider.isLoading;
        final error = walletProvider.error;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Wallet',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error))
              : summary == null
              ? const Center(child: Text('No wallet data found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(context, summary.withdrawable),
                      const SizedBox(height: 24),
                      _buildStatsGrid(summary,context),
                      const SizedBox(height: 24),
                      _buildTransactionHistoryHeader(),
                      const SizedBox(height: 16),
                      ...transactions.map(
                        (tran) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTransactionItem(
                            transactionId: tran.id,
                            amount: tran.amount.toStringAsFixed(2),
                            date: tran.createdAt.toString(),
                            status: tran.status,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildBalanceCard(BuildContext context, double withdrawable) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                width: 150,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Withdrawable Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${withdrawable.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showWithdrawalSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send Withdraw Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


Widget _buildStatsGrid(WalletSummary summary, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  final stats = [
    {
      'colors': [const Color(0xFF34D399), const Color(0xFF059669)],
      'amount': '${summary.withdrawn.toStringAsFixed(0)} ETB',
      'label': 'Withdrawn',
    },
    {
      'colors': [const Color(0xFFF97316), const Color(0xFFEA580C)],
      'amount': '${summary.onHold.toStringAsFixed(0)} ETB',
      'label': 'Pending Withdrawn',
    },
    {
      'colors': [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
      'amount': '${summary.totalSales.toStringAsFixed(0)} ETB',
      'label': 'Total Sales',
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 for tablet
      final aspectRatio = screenWidth > 600 ? 2.0 : 1.6;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatCard(
            colors: stat['colors'] as List<Color>,
            amount: stat['amount'] as String,
            label: stat['label'] as String,
          );
        },
      );
    },
  );
}

  Widget _buildStatCard({
    required List<Color> colors,
    required String amount,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {}, // TODO: Implement View All
          child: const Text(
            'View All →',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String transactionId,
    required String amount,
    required String date,
    String? status,
  }) {
    Color statusColor = status == 'Denied' ? Colors.red : Colors.green;
    IconData statusIcon = status == 'Denied'
        ? Icons.cancel_outlined
        : Icons.check_circle_outline;

    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black12,
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
                  'Transaction# $transactionId',
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
                    '$amount ETB',
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
            Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            if (status != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
