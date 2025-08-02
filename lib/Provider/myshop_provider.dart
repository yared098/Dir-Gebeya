import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
import '../utils/catchMechanisem.dart'; // 👈 Make sure this import is correct

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
    required this.view,
  });

  factory MyShop.fromJson(Map<String, dynamic> json) {
    return MyShop(
      storeName: json['store_name'],
      storeContactNumber: json['store_contact_number'],
      storeAddress: json['store_address'],
      storeProfilePhoto: json['store_profile_photo'],
      totalBalance: json['total_balance'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      coverTextColor: json['store_meta']?['cover_text_color'] ?? '#000000',
      view: json['view'] ?? 0,
      coverShowVendorName: json['store_meta']?['cover_show_vendor_name'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'store_contact_number': storeContactNumber,
      'store_address': storeAddress,
      'store_profile_photo': storeProfilePhoto,
      'total_balance': totalBalance,
      'total_products': totalProducts,
      'view': view,
      'store_meta': {
        'cover_text_color': coverTextColor,
        'cover_show_vendor_name': coverShowVendorName ? 1 : 0,
      },
    };
  }
}

class MyShopProvider extends ChangeNotifier {
  static const String _cacheKey = 'cached_shop';
  bool _isLoading = false;
  String? _error;
  MyShop? _shop;

  bool get isLoading => _isLoading;
  String? get error => _error;
  MyShop? get shop => _shop;
Future<void> fetchShopDetails({bool forceRefresh = false}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  final isOnline = await IsConnected();

  if (!isOnline && !forceRefresh) {
    final cached = await LoadCachedData(_cacheKey);
    if (cached != null) {
      try {
        _shop = MyShop.fromJson(cached);
        _error = null;
      } catch (_) {
        _error = "Couldn't load cached shop data. Please try again.";
      }
    } else {
      _error = "You're offline and no saved shop data was found.";
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  final token = await TokenStorage.getToken();
  if (token == null) {
    _error = "Missing token. Please login again.";
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
      await CacheData(_cacheKey, data);
      _error = null;
    } else {
      _error = "Failed to load shop (${response.statusCode})";
    }
  } catch (e) {
    _error = "An error occurred. Please check your internet connection.";
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
      _error = "Unauthorized. Please log in again.";
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
        await fetchShopDetails(forceRefresh: true); // 🔁 Refresh
        return true;
      } else {
        _error = "Failed to update shop (${response.statusCode})";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Update failed. Please check your connection.";
      notifyListeners();
      return false;
    }
  }
}
