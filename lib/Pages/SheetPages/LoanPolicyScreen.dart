import 'package:flutter/material.dart';

class LoanPolicyScreen extends StatefulWidget {
  const LoanPolicyScreen({super.key});

  @override
  State<LoanPolicyScreen> createState() => _LoanPolicyScreenState();
}

class _LoanPolicyScreenState extends State<LoanPolicyScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Loan Policy", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 1,
          color: Colors.white,
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
                        children: const [
                          Text(
                            "Business Loan Policy",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            """
1. Introduction
This policy outlines the procedures and conditions under which loans are issued to businesses using our platform.

2. Eligibility
Businesses must have a valid registration, minimum operational history of 6 months, and demonstrate consistent transactional activity on the platform.

3. Loan Types
We offer short-term working capital loans, inventory loans, and invoice financing. Each loan type has specific qualification criteria.

4. Interest Rates
Interest rates are determined based on business risk assessment and may vary between 1% to 5% per month.

5. Repayment Terms
Loan repayment periods range from 30 to 180 days. Early repayments may be allowed without penalty depending on the loan agreement.

6. Disbursement
Approved loans are disbursed directly to the registered bank account of the business within 2-3 business days.

7. Late Payments
Late repayments will incur a penalty fee of 2% per month on the outstanding balance.

8. Default & Recovery
Failure to repay loans on time may result in suspension of platform access and recovery through legal means.

9. Confidentiality
All loan application data is treated as confidential and will not be shared with third parties without consent.

10. Amendments
This loan policy may be revised at any time. Businesses will be notified of updates through email or platform notification.
                            """,
                            style: TextStyle(height: 1.5, color: Colors.black87),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "For any questions regarding loans, please contact our support team.",
                            style: TextStyle(fontWeight: FontWeight.w500),
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
                          backgroundColor: Theme.of(context).primaryColor,
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
