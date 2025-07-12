import 'dart:convert';
import 'dart:io';
import 'package:dirgebeya/Provider/RequestProvider.dart';

import 'package:dirgebeya/utils/token_storage.dart';
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
      // Permission denied
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

  Future<void> _openCamera1() async {
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
        fingerprintData: "sample_fingerprint_data", // Replace with actual scanner later
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Page'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nationalIdController,
                decoration: const InputDecoration(labelText: 'National ID'),
                validator: (value) =>
                    value!.isEmpty ? 'National ID is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carLibNumberController,
                decoration:
                    const InputDecoration(labelText: 'Car Library Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Car Library Number is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture Image"),
              ),
              const SizedBox(height: 10),
              _capturedImage != null
                  ? Image.file(_capturedImage!, height: 150)
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              const Text("Fingerprint Scan Placeholder ✅"),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // You can use Navigator to push Terms page
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Terms & Conditions"),
                      content: const Text(
                          "By submitting, you accept all terms and conditions."),
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
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRequest,
                child: const Text("Submit Request"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
