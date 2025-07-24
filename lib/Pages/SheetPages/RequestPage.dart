import 'dart:io';
import 'package:dirgebeya/Provider/RequestProvider.dart';
import 'package:dirgebeya/config/color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _carLibNumberController = TextEditingController();
  File? _capturedImage;

  Future<void> _openCamera() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required.')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _capturedImage = File(pickedImage.path);
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<RequestProvider>(context, listen: false);
      provider.sendRequest(
        nationalId: _nationalIdController.text,
        carLibNumber: _carLibNumberController.text,
        imageFile: _capturedImage,
        fingerprintData: "sample_fingerprint_data", // Replace with actual data
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge!.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Request'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // National ID
              TextFormField(
                controller: _nationalIdController,
                decoration: _inputDecoration("National ID", isDark),
                validator: (value) =>
                    value!.isEmpty ? 'National ID is required' : null,
              ),
              const SizedBox(height: 16),

              // Car Lib Number
              TextFormField(
                controller: _carLibNumberController,
                decoration: _inputDecoration("Car Library Number", isDark),
                validator: (value) =>
                    value!.isEmpty ? 'Car Library Number is required' : null,
              ),
              const SizedBox(height: 20),

              // Camera Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                  foregroundColor: isDark ? Colors.white : Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture Image"),
              ),
              const SizedBox(height: 16),

              // Image Preview
              if (_capturedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _capturedImage!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                  ),
                  child: Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Icon(Icons.fingerprint, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    "Fingerprint Scan Placeholder ✅",
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Terms Button
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: cardColor,
                      title: const Text("Terms & Conditions"),
                      content: const Text(
                        "By submitting, you accept all terms and conditions.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        )
                      ],
                    ),
                  );
                },
                child: const Text(
                  "Read Terms & Conditions",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit Request",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
    );
  }
}
