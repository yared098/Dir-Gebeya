import 'dart:convert';
import 'dart:io';
import 'package:dirgebeya/config/api_config.dart';
import 'package:dirgebeya/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestProvider extends ChangeNotifier {
  bool _isSending = false;
  String? _error;

  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> sendRequest({
    required String nationalId,
    required String carLibNumber,
    required File? imageFile,
    required String fingerprintData,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Missing token";
      _isSending = false;
      notifyListeners();
      return;
    }

    try {
      final uri = Uri.parse("${ApiConfig.baseUrl}/submit_request");
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['national_id'] = nationalId
        ..fields['car_lib_number'] = carLibNumber
        ..fields['fingerprint'] = fingerprintData;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("Request Success: $data");
      } else {
        _error = "Request failed with code ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error sending request: $e";
    }

    _isSending = false;
    notifyListeners();
  }
}
