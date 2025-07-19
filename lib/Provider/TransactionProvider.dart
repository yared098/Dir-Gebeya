import 'dart:convert';
import 'package:dirgebeya/Model/Transaction.dart' show Transaction;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/token_storage.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        _error = 'Missing auth token';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('https://direthiopia.com/api/v3/seller/wallet_api?action=transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _transactions = (data['transactions'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
