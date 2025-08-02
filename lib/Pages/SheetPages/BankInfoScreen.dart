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
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text("Failed to submit bank information")),
              ],
            ),
            backgroundColor: Colors.redAccent,
          ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Fill in your bank details accurately. This ensures your future transactions go smoothly.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isBannerVisible = false;
                      });
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BankingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bank Information'),
        centerTitle: true,

        backgroundColor: Colors.white,
      ),
      body: 
            // dismiss keyboard on outside tap
               SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoBanner(),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _holderNameController,
                            decoration: _inputDecoration(
                              'Holder Name',
                              Icons.person,
                            ),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Please enter holder name'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _bankNameController,
                            decoration: _inputDecoration(
                              'Bank Name',
                              Icons.account_balance,
                            ),
                            validator: (value) => value!.trim().isEmpty
                                ? 'Please enter bank name'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _branchController,
                            decoration: _inputDecoration(
                              'Branch',
                              Icons.location_city,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _accountNumberController,
                            decoration: _inputDecoration(
                              'Account Number',
                              Icons.confirmation_num,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.trim().isEmpty
                                ? 'Please enter account number'
                                : null,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          // TextFormField(
                          //   controller: _ifscCodeController,
                          //   decoration: _inputDecoration('IFSC Code', Icons.code),
                          //   textInputAction: TextInputAction.done,
                          // ),
                          // const SizedBox(height: 36),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
}
