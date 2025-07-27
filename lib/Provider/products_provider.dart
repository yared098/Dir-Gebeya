import 'dart:convert';
import 'package:dirgebeya/Model/Product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';



// class ProductsProvider extends ChangeNotifier {
//   bool _isLoading = false;
//   String? _error;
//   List<Product> _products = [];

//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   List<Product> get products => _products;

//   Future<void> fetchProducts() async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     final token = await TokenStorage.getToken();
//     if (token == null) {
//       _error = "Missing token";
//       _isLoading = false;
//       notifyListeners();
//       return;
//     }

//     final url = Uri.parse('${ApiConfig.baseUrl}/products_api');

//     try {
//       final response = await http.get(url, headers: {
//         'Authorization': 'Bearer $token',
//       });
//       print("here_"+response.body.toString());

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _products = (data['products'] as List)
//             .map((json) => Product.fromJson(json))
//             .toList();
//       } else {
//         _error = "Failed to load products (${response.statusCode})";
//       }
//     } catch (e) {
//       _error = "Error: $e";
//       print("error_"+_error.toString());
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<bool> updateProduct({
//     required String productId,
//     required String productName,
//     required String productPrice,
//   }) async {
//     final token = await TokenStorage.getToken();
//     if (token == null) {
//       _error = "Missing token";
//       notifyListeners();
//       return false;
//     }

//     final url = Uri.parse('${ApiConfig.baseUrl}/products_api');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'product_id': productId,
//           'product_name': productName,
//           'product_price': productPrice,
//         },
//       );

//       if (response.statusCode == 200) {
//         // Optionally refresh product list after update
//         await fetchProducts();
//         return true;
//       } else {
//         _error = "Update failed (${response.statusCode})";
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = "Error: $e";
//       notifyListeners();
//       return false;
//     }
//   }
// }


class ProductsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Product> _products = [];
  bool _hasFetched = false; // ✅ NEW

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get products => _products;

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    // ✅ Don't fetch again if already fetched, unless forced
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

    final url = Uri.parse('${ApiConfig.baseUrl}/products_api');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      print("here_" + response.body.toString());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _products = (data['products'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
        _hasFetched = true; // ✅ Caching flag
      } else {
        _error = "Failed to load products (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
      print("error_" + _error.toString());
    }

    _isLoading = false;
    notifyListeners();
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
        await refreshProducts(); // ✅ Refresh after update
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