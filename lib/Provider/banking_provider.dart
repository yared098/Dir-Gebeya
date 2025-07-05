import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class BankingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get success => _success;

  Future<bool> addPaymentDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String ifscCode,
    String status = "1",
  }) async {
    _isLoading = true;
    _error = null;
    _success = false;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing auth token';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/add_payment');

    final body = jsonEncode({
      "bank_name": bankName,
      "account_number": accountNumber,
      "account_name": accountName,
      "ifsc_code": ifscCode,
      "status": status,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _success = true;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to add payment details: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
