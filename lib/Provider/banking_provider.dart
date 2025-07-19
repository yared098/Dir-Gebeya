import 'dart:convert';

import 'package:dirgebeya/config/api_config.dart';
import 'package:dirgebeya/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BankingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _success = false;

  // New fields for fetched bank info
  String? bankName;
  String? accountNumber;
  String? accountName;
  String? branch;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get success => _success;

  // Your existing addPaymentDetails method here...

  // New method to fetch bank info
  Future<void> fetchBankInfo() async {
    _isLoading = true;
    _error = null;
    notifyListeners();


    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing auth token';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/profile_api'); // Adjust API URL
    print("url_bank"+url.toString());
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          print("bankdata"+data.toString());
      
        // Assign fetched data (adjust keys to your API)
        bankName = data['bank_name'] ?? '';
        accountNumber = data['account_number'] ?? '';
        accountName = data['account_name'] ?? '';
        branch = data['branch'] ?? '';
      } else {
        _error = 'Failed to load bank info: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
