import 'dart:ui';

import 'package:flutter/material.dart';

class BankInfoScreen extends StatefulWidget {
  const BankInfoScreen({super.key});

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  bool _isBannerVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
    onPressed: () {
      Navigator.pop(context); // 🔁 Go back to previous screen
    },
  ),
        title: const Text(
          'Bank Info',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 16),
            _buildEditButton(),
            const SizedBox(height: 16),
            _buildBankInfoCard(),
          ],
        ),
      ),
    );
  }

  // Builds the dismissible info banner at the top
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

  // Builds the "Edit Bank Info" button
  Widget _buildEditButton() {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // Handle navigation to edit screen
        },
        title: Text(
          'Edit Bank Info',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
      ),
    );
  }

  // Builds the main card displaying the bank account details
  Widget _buildBankInfoCard() {
    return Card(
      elevation: 1,
      color: Colors.white,
clipBehavior: Clip.antiAlias, // Ensures the background image respects the card's border radius
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Faint background credit card image
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://i.imgur.com/2f2d4sV.png', // Transparent credit card PNG
                width: 200,
                color: Colors.blueGrey,
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.person, size: 28, color: Colors.black54),
                    SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Holder Name : ',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Fatema',
                            style: TextStyle(
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
                _buildDetailRow('Bank', 'City Bank'),
                const SizedBox(height: 16),
                _buildDetailRow('Branch', 'Mirpur- 12'),
                const SizedBox(height: 16),
                _buildDetailRow('A/C No.', '12345678'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create a row for a single bank detail
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