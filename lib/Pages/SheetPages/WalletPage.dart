import 'package:dirgebeya/Pages/SheetPages/WithdrawalForm.dart';
import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  
  void _showWithdrawalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        // Wrap with Padding to handle view insets (like the keyboard)
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () {
            Navigator.pop(context); // 🔁 Go back to previous screen
          },
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top card for withdrawable balance
              _buildBalanceCard(context),
              const SizedBox(height: 24),

              // Grid of statistics cards
              _buildStatsGrid(),
              const SizedBox(height: 24),

              // Transaction history section
              _buildTransactionHistoryHeader(),
              const SizedBox(height: 16),
              _buildTransactionItem(
                transactionId: '11',
                amount: '500.00',
                date: '12-Oct-2022 12:39 AM',
                status: 'Denied',
              ),
              const SizedBox(height: 12),
              _buildTransactionItem(
                transactionId: '10',
                amount: '600.00',
                date: '11-Oct-2022 10:25 PM', // Added a sample date
                // No status means it will not be displayed
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main blue card showing the withdrawable balance.
  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB), // Main blue color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative wave-like shapes for a modern touch
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
                  color: const Color(
                    0xFF1D4ED8,
                  ).withOpacity(0.8), // Darker blue
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ),
          // Main content of the balance card
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
                const Text(
                  '\$10,023.50',
                  style: TextStyle(
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

  /// Builds the 2-column grid of statistical data.
  Widget _buildStatsGrid() {
    // Data for the grid items
    final stats = [
      {
        'colors': [const Color(0xFF34D399), const Color(0xFF059669)],
        'amount': '\$600.00',
        'label': 'Withdrawn',
      },
      {
        'colors': [const Color(0xFFF97316), const Color(0xFFEA580C)],
        'amount': '\$500.00',
        'label': 'Pending Withdrawn',
      },
      {
        'colors': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        'amount': '\$6,394.47',
        'label': 'Commission Given',
      },
      {
        'colors': [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
        'amount': '\$822.00',
        'label': 'Delivery Charge Earned',
      },
      {
        'colors': [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
        'amount': '\$25,756.80',
        'label': 'Collected Cash',
      },
      {
        'colors': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        'amount': '\$2,519.00',
        'label': 'Total Collected Tax',
      },
    ];

    return GridView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for the grid
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.7, // Adjust ratio for better layout
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
  }

  /// Builds a single card for the statistics grid.
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

  /// Builds the header for the transaction history list.
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
          onPressed: () {},
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

  /// Builds a card for a single transaction item.
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
                    '\$$amount',
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
            // Conditionally display the status row if a status is provided
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
