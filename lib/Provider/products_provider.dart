import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class Product {
  final int productId;
  final String productName;
  final double productPrice;
  final String productImage;

  Product({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      productName: json['product_name'],
      productPrice: (json['product_price'] as num).toDouble(),
      productImage: json['product_featured_image'],
    );
  }
}

class ProductsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Missing token";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/products_api');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        _error = "Failed to load products (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProduct({
    required String productId,
    required String productName,
    required String productPrice,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Missing token";
      notifyListeners();
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/products_api');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'product_id': productId,
          'product_name': productName,
          'product_price': productPrice,
        },
      );

      if (response.statusCode == 200) {
        // Optionally refresh product list after update
        await fetchProducts();
        return true;
      } else {
        _error = "Update failed (${response.statusCode})";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error: $e";
      notifyListeners();
      return false;
    }
  }
}
