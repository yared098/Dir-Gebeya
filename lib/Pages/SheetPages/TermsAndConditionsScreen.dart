import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        if (!_isAtBottom) {
          setState(() => _isAtBottom = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          color: theme.cardColor,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "B2B Business Terms & Conditions",
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            """
1. Introduction
Welcome to our B2B platform. By accessing or using our services, you agree to be bound by the following terms.

2. Business Registration
All businesses must be legally registered and provide valid credentials. We reserve the right to verify any submitted business information.

3. Order & Payment
Orders placed via the platform are binding. Payments must be completed using the agreed payment method (e.g., credit, bank transfer, or cash on delivery) within the specified payment window.

4. Delivery & Logistics
Delivery timelines are estimates and not guaranteed. We are not liable for delays caused by third-party logistics providers.

5. Returns & Refunds
All returns must be initiated within 7 business days of delivery. Products must be unused, in original packaging. Refunds are subject to inspection.

6. Pricing & Taxes
All prices are exclusive of applicable taxes unless stated otherwise. Buyers are responsible for any local or import duties.

7. Data & Privacy
We will store your business and transactional data securely and will not share it without your consent unless required by law.

8. Termination
We reserve the right to suspend or terminate your access if any fraudulent or unethical behavior is detected.

9. Dispute Resolution
All disputes shall be governed under local commercial laws. Parties agree to resolve disputes amicably or through arbitration if necessary.

10. Changes
We may modify these terms at any time. Continued use of the platform after changes means you accept the updated terms.
                            """,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Thank you for choosing our platform for your B2B needs.",
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isAtBottom)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Close", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
