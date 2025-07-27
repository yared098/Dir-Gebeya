import 'package:dirgebeya/Provider/banking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BankInfoForm extends StatefulWidget {
  const BankInfoForm({super.key});

  @override
  State<BankInfoForm> createState() => _BankInfoFormState();
}

class _BankInfoFormState extends State<BankInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();

  bool _isBannerVisible = true;

  @override
  void dispose() {
    _holderNameController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<BankingProvider>(context, listen: false);

      bool success = await provider.addPaymentDetails(
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountName: _holderNameController.text.trim(),
        ifscCode: _ifscCodeController.text.trim(),
        branch: _branchController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank info submitted successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to submit')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BankingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bank Info'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              TextFormField(
                                controller: _holderNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Holder Name',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter holder name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _bankNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Bank Name',
                                  prefixIcon: Icon(Icons.account_balance),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter bank name' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _branchController,
                                decoration: const InputDecoration(
                                  labelText: 'Branch',
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _accountNumberController,
                                decoration: const InputDecoration(
                                  labelText: 'Account Number',
                                  prefixIcon: Icon(Icons.confirmation_num),
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty ? 'Please enter account number' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ifscCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'IFSC Code',
                                  prefixIcon: Icon(Icons.code),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _submit,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Submit', style: TextStyle(fontSize: 16)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
