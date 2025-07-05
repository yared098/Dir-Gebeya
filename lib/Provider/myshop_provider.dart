import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class MyShop {
  final String storeName;
  final String storeContactNumber;
  final String storeAddress;
  final String? storeProfilePhoto;
  final int totalBalance;
  final int totalProducts;
  final String coverTextColor;
  final bool coverShowVendorName;

  MyShop({
    required this.storeName,
    required this.storeContactNumber,
    required this.storeAddress,
    this.storeProfilePhoto,
    required this.totalBalance,
    required this.totalProducts,
    required this.coverTextColor,
    required this.coverShowVendorName,
  });

  factory MyShop.fromJson(Map<String, dynamic> json) {
    return MyShop(
      storeName: json['store_name'],
      storeContactNumber: json['store_contact_number'],
      storeAddress: json['store_address'],
      storeProfilePhoto: json['store_profile_photo'],
      totalBalance: json['total_balance'],
      totalProducts: json['total_products'],
      coverTextColor: json['store_meta']['cover_text_color'] ?? '#000000',
      coverShowVendorName:
          (json['store_meta']['cover_show_vendor_name'] == 1),
    );
  }
}

class MyShopProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  MyShop? _shop;

  bool get isLoading => _isLoading;
  String? get error => _error;
  MyShop? get shop => _shop;

  Future<void> fetchShopDetails() async {
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

    final url = Uri.parse('${ApiConfig.baseUrl}/shop_api');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _shop = MyShop.fromJson(data);
      } else {
        _error = "Failed to load shop (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
