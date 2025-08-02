import 'dart:convert';
import 'dart:io';
import 'package:dirgebeya/Model/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
import '../utils/catchMechanisem.dart'; // caching utils
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? _earningsData;
  String? _error;
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get overviewData => _overviewData;
  Map<String, dynamic>? get earningsData => _earningsData;
  String? get error => _error;

  Future<void> fetchOverview({bool force = false}) async {
    if (_overviewData == null || force) {
      _isLoading = true;
      notifyListeners();
    }

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "User not authenticated.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (await IsConnected()) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.dashboard}?action=overview'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            _overviewData = decoded;
            await CacheData('dashboard_overview', _overviewData);
            _error = null;
          } else {
            _error = "Invalid data format for overview";
          }
        } else {
          _error = "Failed to load dashboard data";
        }
      } catch (e) {
        _error = "An error occurred: $e";
      }
    } else {
      // Offline: load cached data, no error message if cache exists
      final cached = await LoadCachedData('dashboard_overview');
      if (cached != null && cached is Map<String, dynamic>) {
        _overviewData = cached;
        _error = null; // suppress error because cache is available
      } else {
        _error = "No internet and no cached data.";
      }
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

    if (await IsConnected()) {
      try {
        final response = await http.get(
          Uri.parse("${ApiConfig.dashboard}?action=products"),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final productsJson = data['products'];
          if (productsJson is List) {
            _products = productsJson.map((p) => ProductModel.fromJson(p)).toList();
            await CacheData('dashboard_products', productsJson);
            _error = null;
          } else {
            _error = "Invalid product data format";
          }
        } else {
          // fallback to cache on bad status
          final cached = await LoadCachedData('dashboard_products');
          if (cached != null && cached is List) {
            _products = cached.map((p) => ProductModel.fromJson(p)).toList();
            _error = null;  // suppress error because cache is available
          } else {
            _error = 'No internet and no cached product data.';
          }
        }
      } catch (e) {
        // fallback to cache on exception
        final cached = await LoadCachedData('dashboard_products');
        if (cached != null && cached is List) {
          _products = cached.map((p) => ProductModel.fromJson(p)).toList();
          _error = null;  // suppress error because cache is available
        } else {
          _error = 'No internet and no cached product data.';
        }
      }
    } else {
      // Offline: load cached data
      final cached = await LoadCachedData('dashboard_products');
      if (cached != null && cached is List) {
        _products = cached.map((p) => ProductModel.fromJson(p)).toList();
        _error = null;
      } else {
        _error = "No internet and no cached product data.";
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEarningsStats({
    required String sellerId,
    required String type,
  }) async {
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

    final cacheKey = 'earnings_${sellerId}_$type';

    if (await IsConnected()) {
      try {
        final uri = Uri.parse(
          '${ApiConfig.dashboard}?seller_id=$sellerId&action=earnings&type=$type',
        );
        final response = await http.get(uri, headers: {
          'Authorization': 'Bearer $token',
        });

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            _earningsData = decoded;
            await CacheData(cacheKey, _earningsData);
            _error = null;
          } else {
            _error = "No internet and no cached product data.";
          }
        } else {
          _error = "No internet and no cached product data.";
        }
      } catch (e) {
        _error = "No internet and no cached product data.";
      }
    } else {
      final cached = await LoadCachedData(cacheKey);
      if (cached != null && cached is Map<String, dynamic>) {
        _earningsData = cached;
        _error = null;
      } else {
        _error = "No internet and no cached earnings data.";
      }
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

      if (response.statusCode == 200) {
        await fetchTopProducts(); // Refresh
        _error = null;
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
