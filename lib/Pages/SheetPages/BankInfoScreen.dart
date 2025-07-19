import 'package:dirgebeya/Provider/banking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({super.key});

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  bool _isBannerVisible = true;

  @override
  void initState() {
    super.initState();
    // Fetch bank info once screen loads
    Future.microtask(() {
      Provider.of<BankingProvider>(context, listen: false).fetchBankInfo();
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bank Info',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<BankingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoBanner(),
                const SizedBox(height: 16),
                _buildEditButton(),
                const SizedBox(height: 16),
                _buildBankInfoCard(
                  accountName: provider.accountName ?? 'N/A',
                  bankName: provider.bankName ?? 'N/A',
                  branch: provider.branch ?? 'N/A',
                  accountNumber: provider.accountNumber ?? 'N/A',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _isBannerVisible
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0EFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF0D6EFD)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'You should fill-up this information correctly as this will be helpful for future transactions.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isBannerVisible = false;
                      });
                    },
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildEditButton() {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // TODO: Navigate to edit bank info screen
        },
        title: Text(
          'Edit Bank Info',
          style: TextStyle(
              color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildBankInfoCard({
    required String accountName,
    required String bankName,
    required String branch,
    required String accountNumber,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://i.imgur.com/2f2d4sV.png',
                width: 200,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 28, color: Colors.black54),
                    const SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Holder Name : ',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                        children: [
                          TextSpan(
                            text: accountName,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDetailRow('Bank', bankName),
                const SizedBox(height: 16),
                _buildDetailRow('Branch', branch),
                const SizedBox(height: 16),
                _buildDetailRow('A/C No.', accountNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}