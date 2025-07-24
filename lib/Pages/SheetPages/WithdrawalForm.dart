import 'package:dirgebeya/Provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WithdrawalForm extends StatefulWidget {
  const WithdrawalForm({super.key});

  @override
  State<WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<WithdrawalForm> {
  String? _selectedCard = 'Visionfund';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            const SizedBox(height: 24),

            // Dropdown for card selection
            DropdownButtonFormField<String>(
              value: _selectedCard,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black54,
              ),
              decoration: const InputDecoration(),
              items: ['Visionfund', 'Hibret Bank']
                  .map(
                    (label) => DropdownMenuItem(
                      value: label,
                      child: Text(
                        label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCard = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Text field for name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter Name'),
            ),
            const SizedBox(height: 16),

            // Text field for card number
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Card Number'),
            ),
            const SizedBox(height: 32),

            // Amount field
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ex: 500 ETB'),
            ),
            const SizedBox(height: 24),

            // Dashed Divider
            const DashedDivider(),
            const SizedBox(height: 24),

            // Withdrawn button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final name = _nameController.text.trim();
                        final cardNumber = _cardNumberController.text.trim();
                        final amount = _amountController.text.trim();
                        final method = _selectedCard ?? 'Visionfund';

                        if (name.isEmpty ||
                            cardNumber.isEmpty ||
                            amount.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        setState(() => _isLoading = true); // Start loading

                        final now = DateTime.now();
                        final formattedTime =
                            '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} '
                            '${_twoDigits(now.hour)}-${_twoDigits(now.minute)}-${_twoDigits(now.second)}';

                        final success =
                            await Provider.of<WalletProvider>(
                              context,
                              listen: false,
                            ).sendWithdrawalRequest(
                              tranIds: "292",
                              total: amount,
                              preferMethod: "$method Acc",
                              settings: cardNumber,
                              createdTime: formattedTime,
                            );

                        setState(() => _isLoading = false); // Stop loading

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Withdrawal request submitted successfully',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          final error =
                              Provider.of<WalletProvider>(
                                context,
                                listen: false,
                              ).error ??
                              "Unknown error";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Withdrawal failed: $error'),
                            ),
                          );
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Withdraw',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Custom widget for the dashed line
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key, this.height = 1, this.color = Colors.grey});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
