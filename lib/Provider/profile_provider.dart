import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String avatar;
  final int totalProducts;
  final int totalWalletBalance;
  final int totalOrders;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.totalProducts,
    required this.totalWalletBalance,
    required this.totalOrders,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    return UserProfile(
      firstName: profile['firstname'],
      lastName: profile['lastname'],
      email: profile['email'],
      phone: profile['phone'],
      avatar: profile['avatar'],
      totalProducts: json['total_products'] ?? 0,
      totalWalletBalance: json['total_wallet_balance'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
    );
  }
}

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  UserProfile? _userProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile? get userProfile => _userProfile;

  Future<void> fetchProfile() async {
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

    final url = Uri.parse('${ApiConfig.baseUrl}/profile_api');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print("token_pr" + token);

      if (response.statusCode == 200) {
        print("profile1" + response.body.toString());
        final data = jsonDecode(response.body);
        _userProfile = UserProfile.fromJson(data);
      } else {
        _error = "Failed to load profile (${response.statusCode})";
      }
    } catch (e) {
      _error = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// New logout function calling API and clearing token on success
  Future<bool> logout() async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/logout_api');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Logout success: clear stored token
        print("logout success" + response.body);
        await TokenStorage.clearToken();
        _userProfile = null;
        notifyListeners();
        return true;
      } else {
        _error = "Logout failed (${response.statusCode})";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Logout error: $e";
      notifyListeners();
      return false;
    }
  }

Future<bool> uploadProfileImage(File imageFile) async {
  final token = await TokenStorage.getToken();
  if (token == null) return false;

  // Check file size: max 2MB
  final int maxFileSize = 2 * 1024 * 1024; // 2MB in bytes
  final int fileSize = await imageFile.length();

  if (fileSize > maxFileSize) {
    _error = "Image size should not exceed 2MB.";
    notifyListeners();
    return false;
  }

  final url = Uri.parse('${ApiConfig.baseUrl}/profile_api');

  try {
    final mimeType =
        lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'profile_pic',
          imageFile.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      await fetchProfile(); // refresh profile with new avatar
      return true;
    } else {
      _error = "Upload failed (${response.statusCode})";
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = "Upload error: $e";
    notifyListeners();
    return false;
  }
}


}
