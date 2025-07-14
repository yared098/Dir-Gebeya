import 'dart:convert';
import 'package:dirgebeya/Model/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _earningsData;  // NEW
  String? _error;
 List<ProductModel> _products = [];
 List<ProductModel> get products => _products;


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
  
// Future<void> fetchTopProducts() async {
//   try {
//     _isLoading = true;
//     notifyListeners();

//     final token = await TokenStorage.getToken();
//     if (token == null) {
//       _error = "User not authenticated.";
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     final response = await http.get(
//       Uri.parse('https://direthiopia.com/api/v3/seller/dashboard_api?action=products'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("dash_products"+data.toString());
//       final productList = data['products'] as List<dynamic>;
//       _products = productList.map((p) => ProductModel.fromJson(p)).toList();
//     } else {
//       _error = 'Failed to fetch products';
//     }
//   } catch (e) {
//     _error = e.toString();
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }


Future<void> fetchTopProducts() async {
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
      Uri.parse("https://direthiopia.com/api/v3/seller/dashboard_api?action=products"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ dash_products: $data");
      final List<dynamic> productsJson = data['products'] ?? [];
      _products = productsJson.map((p) => ProductModel.fromJson(p)).toList();
    } else {
      _error = '❌ Failed to load products (status: ${response.statusCode})';
    }
  } catch (e) {
    _error = '❌ Error fetching products: $e';
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
