import 'dart:convert';
import 'package:dirgebeya/Model/Transaction.dart' show Transaction;
import 'package:dirgebeya/utils/catchMechanisem.dart';  // Your cache utils
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

  static const String _cacheKey = 'cached_transactions';

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    if (_transactions.isNotEmpty && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final isOnline = await IsConnected();

    if (!isOnline) {
      // Offline: Load from cache
      final cached = await LoadCachedData(_cacheKey);
      if (cached != null) {
        try {
          // Use the correct key 'transactions'
          List cachedList = cached['transactions'] ?? [];
          _transactions = cachedList.map((e) => Transaction.fromJson(e)).toList();
          _error = null;
        } catch (e) {
          _error = "Failed to load cached transactions.";
          _transactions = [];
        }
      } else {
        _error = "No internet connection and no cached transactions available.";
        _transactions = [];
      }

      _isLoading = false;
      notifyListeners();
      return;
    }

    // Online: fetch from API
    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Missing token";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uri = Uri.parse('https://direthiopia.com/api/v3/seller/wallet_api?action=transactions');

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['transactions'] != null) {
          _transactions = (data['transactions'] as List)
              .map((e) => Transaction.fromJson(e))
              .toList();

          // Cache the full response including 'transactions' key
          await CacheData(_cacheKey, data);
          _error = null;
        } else {
          _transactions = [];
          _error = "No transactions found.";
        }
      } else {
        _error = "Failed to load transactions: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Error fetching transactions: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
