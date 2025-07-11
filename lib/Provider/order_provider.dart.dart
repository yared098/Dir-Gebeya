import 'dart:convert';

import 'package:dirgebeya/Model/Order.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';


class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Order> _orders = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;
  String? get error => _error;

  Future<void> fetchOrders() async {
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
        Uri.parse(ApiConfig.orders),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("rsporder: ${response.body}"); // Correct way
        if (jsonData['order'] != null) {
          _orders = (jsonData['order'] as List)
              .map((item) => Order.fromJson(item))
              .toList();
        }
      } else {
        _error = "Failed to load orders";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
