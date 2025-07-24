// import 'package:dirgebeya/Provider/banking_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class BankInfoScreen extends StatefulWidget {
//   const BankInfoScreen({super.key});

//   @override
//   State<BankInfoScreen> createState() => _BankInfoScreenState();
// }

// class _BankInfoScreenState extends State<BankInfoScreen> {
//   bool _isBannerVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch bank info once screen loads
//     Future.microtask(() {
//       Provider.of<BankingProvider>(context, listen: false).fetchBankInfo();
      
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Bank Info',
//           style: TextStyle(color: theme.textTheme.titleLarge?.color, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Consumer<BankingProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (provider.error != null) {
//             return Center(child: Text(provider.error!));
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 _buildInfoBanner(),
//                 const SizedBox(height: 16),
//                 _buildEditButton(),
//                 const SizedBox(height: 16),
//                 _buildBankInfoCard(
//                   accountName: provider.accountName ?? 'N/A',
//                   bankName: provider.bankName ?? 'N/A',
//                   branch: provider.branch ?? 'N/A',
//                   accountNumber: provider.accountNumber ?? 'N/A',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInfoBanner() {
//     return AnimatedSize(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: _isBannerVisible
//           ? Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE0EFFF),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(Icons.lightbulb_outline, color: Color(0xFF0D6EFD)),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'You should fill-up this information correctly as this will be helpful for future transactions.',
//                       style: TextStyle(color: Colors.black54),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   InkWell(
//                     onTap: () {
//                       setState(() {
//                         _isBannerVisible = false;
//                       });
//                     },
//                     child: const Icon(Icons.close, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             )
//           : const SizedBox.shrink(),
//     );
//   }

//   Widget _buildEditButton() {
//     return Card(
//       elevation: 1,
//       color: Colors.white,
//       shadowColor: Colors.grey.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         onTap: () {
//           // TODO: Navigate to edit bank info screen
//         },
//         title: Text(
//           'Edit Bank Info',
//           style: TextStyle(
//               color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
//         ),
//         trailing: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
//       ),
//     );
//   }

//   Widget _buildBankInfoCard({
//     required String accountName,
//     required String bankName,
//     required String branch,
//     required String accountNumber,
//   }) {
//     return Card(
//       elevation: 1,
//       color: Colors.white,
//       clipBehavior: Clip.antiAlias,
//       shadowColor: Colors.grey.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -20,
//             bottom: -10,
//             child: Opacity(
//               opacity: 0.1,
//               child: Image.network(
//                 'https://i.imgur.com/2f2d4sV.png',
//                 width: 200,
//                 color: Colors.blueGrey,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.person, size: 28, color: Colors.black54),
//                     const SizedBox(width: 16),
//                     Text.rich(
//                       TextSpan(
//                         text: 'Holder Name : ',
//                         style: const TextStyle(color: Colors.grey, fontSize: 16),
//                         children: [
//                           TextSpan(
//                             text: accountName,
//                             style: const TextStyle(
//                               color: Colors.black87,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Divider(height: 32),
//                 _buildDetailRow('Bank', bankName),
//                 const SizedBox(height: 16),
//                 _buildDetailRow('Branch', branch),
//                 const SizedBox(height: 16),
//                 _buildDetailRow('A/C No.', accountNumber),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Text.rich(
//       TextSpan(
//         text: '$label : ',
//         style: const TextStyle(
//           color: Colors.grey,
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//         children: [
//           TextSpan(
//             text: value,
//             style: const TextStyle(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
        Navigator.pop(context); // Close form after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to submit')),
        );
      }
    }
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _holderNameController,
                      decoration: const InputDecoration(labelText: 'Holder Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter holder name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(labelText: 'Bank Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter bank name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _branchController,
                      decoration: const InputDecoration(labelText: 'Branch'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(labelText: 'Account Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Please enter account number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ifscCodeController,
                      decoration: const InputDecoration(labelText: 'IFSC Code'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
