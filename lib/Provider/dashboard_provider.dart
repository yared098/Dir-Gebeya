import 'dart:convert';
import 'dart:io';
import 'package:dirgebeya/Model/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


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


 Future<bool> updateProduct({
  required int productId,
  required String name,
  required String price,
  File? imageFile,
}) async {
  final token = await TokenStorage.getToken();
  if (token == null) {
    _error = "Unauthorized";
    notifyListeners();
    return false;
  }

  try {
    final uri = Uri.parse("https://direthiopia.com/api/v3/seller/products_api");

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['product_id'] = productId.toString()
      ..fields['product_name'] = name
      ..fields['product_price'] = price;

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final response = await request.send();
    print(response.toString());

    if (response.statusCode == 200) {
      await fetchTopProducts(); // Optionally refresh data
      return true;
    } else {
      _error = "Failed to update product (${response.statusCode})";
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = "Update error: $e";
    notifyListeners();
    return false;
  }
}

}
