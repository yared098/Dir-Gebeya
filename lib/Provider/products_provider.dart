import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
class Product {
  final int? productId;
  final String name;
  final double price;
  final String imageUrl;
  final String? type;
  final bool hasLimitedStock;

  Product({
    this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.type,
    this.hasLimitedStock = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id'].toString()),
      name: json['product_name'] ?? json['name'] ?? '',
      price: (json['product_price'] ?? json['price'] as num).toDouble(),
      imageUrl: json['product_featured_image'] ?? json['imageUrl'] ?? '',
      type: json['type'],
      hasLimitedStock: json['hasLimitedStock'] == true ||
          json['hasLimitedStock'] == 'true' ||
          json['hasLimitedStock'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': name,
      'product_price': price,
      'product_featured_image': imageUrl,
      'type': type,
      'hasLimitedStock': hasLimitedStock,
    };
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
