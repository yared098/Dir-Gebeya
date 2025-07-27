import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
      firstName: profile['firstname']?? "Guest",
      lastName: profile['lastname']??"Guest",
      email: profile['email']?? "guest@gmail.com",
      phone: profile['phone']??" guest phone",
      avatar: profile['avatar']??"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8AJM9wkP__z2M-hovSAWcTb_9XJ6smy3NKw&s",
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

  /// Fetch profile from API with optional force refresh.
  /// If forceRefresh is false and cached profile exists, returns immediately.
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _userProfile != null) {
      // Use cached data, no loading spinner
      return;
    }

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

      if (response.statusCode == 200) {
           print("profie"+response.body);
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

   Future<bool> updateProfile(String firstName, String lastName, String phone,String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Missing token";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/profile_api'); // Adjust endpoint if needed

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({

          'firstname': firstName,
          'lastname': lastName,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200) {
        print("update resp"+response.body);
        await fetchProfile(forceRefresh: true); // refresh cached profile
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to update profile (${response.statusCode})";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Update error: $e";
      _isLoading = false;
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
      print(response.statusCode.toString()+"uploaded");
      _error = "Upload done (${response.statusCode})";
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

Future<void> updateUserStatusInfo() async {
  final token = await TokenStorage.getToken();
  if (token == null) return;

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permissions are denied';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied';
      notifyListeners();
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final now = DateTime.now().toIso8601String();

    final url = Uri.parse('${ApiConfig.baseUrl}/user_status_api');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': now,
      }),
    );

    if (response.statusCode == 200) {
      print("User status updated");
    } else {
      _error = "Status update failed: ${response.statusCode}";
      notifyListeners();
    }
  } catch (e) {
    _error = "Error updating status: $e";
    notifyListeners();
  }
}


}
