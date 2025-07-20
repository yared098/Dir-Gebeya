import 'dart:convert';
import 'dart:io';
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
  final int view;

  MyShop({
    required this.storeName,
    required this.storeContactNumber,
    required this.storeAddress,
    this.storeProfilePhoto,
    required this.totalBalance,
    required this.totalProducts,
    required this.coverTextColor,
    required this.coverShowVendorName,
    required this .view
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
      view: json['view'],
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
        print("my_shop"+response.body);
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

  Future<bool> updateShopDetails({
  required String name,
  required String contact,
  required String address,
   File? storeProfilePhoto,
}) async {
  final token = await TokenStorage.getToken();
  if (token == null) {
    _error = "Unauthorized";
    notifyListeners();
    return false;
  }

  final url = Uri.parse('${ApiConfig.baseUrl}/shop_api');

  final body = {
    "store_name": name,
    "store_contact_number": contact,
    "store_address": address,
    "store_meta": {
      "cover_text_color": _shop?.coverTextColor ?? "#000000",
      "cover_show_vendor_name": _shop?.coverShowVendorName == true ? 1 : 0,
    },
    "store_profile_photo": null,
    "total_balance": _shop?.totalBalance ?? 0,
    "total_products": _shop?.totalProducts ?? 0,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      await fetchShopDetails(); // refresh UI
      return true;
    } else {
      _error = "Failed to update (${response.statusCode})";
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
