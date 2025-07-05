import 'package:flutter/material.dart';

class VendorProfilePage extends StatelessWidget {
  const VendorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = {
      'name': 'Abebe Kebede',
      'loan': 15000,
      'refundDate': '2025-08-01',
      'interest': '5%',
      'email': 'abebe@example.com',
      'phone': '+251 911 123 456',
      'location': 'Addis Ababa, Ethiopia',
      'profileImg':
          'https://media.istockphoto.com/id/1495088043/vector/user-profile-icon-avatar-or-person-icon-profile-picture-portrait-symbol-default-portrait.jpg?s=612x612&w=0&k=20&c=dhV2p1JwmloBTOaGAtaA3AW1KSnjsdMt7-U_3EZElZ0=', // Replace with real profile image URL
    };

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Profile + Loan Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    /// 🖼️ Profile Circle Image
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(vendor['profileImg']!.toString()),
                    ),
                    const SizedBox(width: 16),

                    /// 📊 Loan Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor['name']!.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Loan Amount: ETB ${vendor['loan']}"),
                          Text("Refund Time: ${vendor['refundDate']}"),
                          Text("Interest: ${vendor['interest']}"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🧾 Additional Vendor Information
            const Text(
              "Vendor Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _buildInfoCard("📧 Email", vendor['email']!.toString()),
            _buildInfoCard("📞 Phone", vendor['phone']!.toString()),
            _buildInfoCard("📍 Location", vendor['location']!.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        title: Text(value),
      ),
    );
  }
}
