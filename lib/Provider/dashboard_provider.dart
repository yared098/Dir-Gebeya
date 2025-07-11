import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _earningsData;  // NEW
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get overviewData => _overviewData;
  Map<String, dynamic>? get earningsData => _earningsData;  // NEW
  String? get error => _error;

  Future<void> fetchOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "User not authenticated.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.dashboard}?action=overview'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _overviewData = jsonDecode(response.body);
        print("dash_provider overview: $_overviewData");
      } else {
        _error = "Failed to load dashboard data";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // New method to fetch earnings stats based on type
  Future<void> fetchEarningsStats({required String sellerId, required String type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "User not authenticated.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final uri = Uri.parse('${ApiConfig.dashboard}?seller_id=$sellerId&action=earnings&type=$type');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        _earningsData = jsonDecode(response.body);
        print("dash_provider earnings: $_earningsData");
      } else {
        _error = "Failed to load earnings data";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
