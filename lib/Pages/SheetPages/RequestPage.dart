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
    final primaryColor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title:  Text('Submit Request',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
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
                decoration: _inputDecoration("National ID"),
                validator: (value) =>
                    value!.isEmpty ? 'National ID is required' : null,
              ),
              const SizedBox(height: 16),

              // Car Lib Number
              TextFormField(
                controller: _carLibNumberController,
                decoration: _inputDecoration("Car Library Number"),
                validator: (value) =>
                    value!.isEmpty ? 'Car Library Number is required' : null,
              ),
              const SizedBox(height: 20),

              // Camera Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.black87,
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
                  ),
                  child: const Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.fingerprint, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    "Fingerprint Scan Placeholder ✅",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
