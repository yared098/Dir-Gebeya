import 'package:flutter/material.dart';

class WithdrawalForm extends StatefulWidget {
  const WithdrawalForm({super.key});

  @override
  State<WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<WithdrawalForm> {
  String? _selectedCard = 'Visionfund';

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
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              decoration: const InputDecoration(),
              items: ['Visionfund', ' Bibret Bank',""]
                  .map((label) => DropdownMenuItem(
                        value: label,
child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCard = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Text field for name
            const TextField(
              decoration: InputDecoration(
                hintText: 'Yohanes',
              ),
            ),
            const SizedBox(height: 16),
            
            // Text field for card number
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '1234 5678 9876',
              ),
            ),
            const SizedBox(height: 32),

            // Amount section
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Inter'),
                children: [
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: 'Ex: 500 ETB'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dashed Divider
            const DashedDivider(),
            const SizedBox(height: 24),

            // Withdrawn button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Withdrawn',
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
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}