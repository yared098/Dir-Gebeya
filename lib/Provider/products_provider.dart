import 'dart:convert';

import 'package:dirgebeya/Model/Product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/token_storage.dart';
import '../utils/catchMechanisem.dart'; // caching utils


class ProductsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];
  bool _hasFetched = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;

  static const _cacheKey = 'cached_products';

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_hasFetched && !forceRefresh) return;

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

    bool online = await IsConnected();

    if (online) {
      // If online, fetch from API and cache
      final url = Uri.parse('${ApiConfig.baseUrl}/products_api');
      try {
        final response = await http.get(url, headers: {
          'Authorization': 'Bearer $token',
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Parse products
          _products = (data['products'] as List)
              .map((json) => Product.fromJson(json))
              .toList();

          // Cache raw JSON data for offline use
          await CacheData(_cacheKey, data['products']);

          _hasFetched = true;
        } else {
          _error = "Failed to load products (${response.statusCode})";

          // Try to load cached data if available
          await _loadFromCache();
        }
      } catch (e) {
        _error = "Error: $e";

        // On error, fallback to cache if possible
        await _loadFromCache();
      }
    } else {
      // If offline, load from cache
      await _loadFromCache();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFromCache() async {
    final cachedData = await LoadCachedData(_cacheKey);
    if (cachedData != null) {
      _products = (cachedData as List)
          .map((json) => Product.fromJson(json))
          .toList();
      _error = null; // clear error because cache is loaded
      _hasFetched = true;
    } else {
      _error ??= "No cached data available";
      _products = [];
    }
  }

  Future<void> refreshProducts() async {
    _hasFetched = false;
    await fetchProducts(forceRefresh: true);
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
        await refreshProducts();
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
