import 'dart:convert';
import 'dart:math';
import 'package:dirgebeya/Model/userModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

import '../utils/token_storage.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  UserModel? _user;
  String? _error;

  bool get isLoading => _isLoading;
  String? get token => _token;
  UserModel? get user => _user;
  String? get error => _error;

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final formattedPhone = convertToInternationalPhone(phone);
      print('Formatted Phone: $formattedPhone');
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json', // 👈 Required for JSON body
        },
        body: jsonEncode({
          // 👈 Send JSON data
          'phone': formattedPhone,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      print("response" + data.toString());

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);

        // Save token securely
        await TokenStorage.saveToken(_token!);

        // ✅ Save phone & password to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_phone', phone);
        await prefs.setString('saved_password', password);
        await prefs.setBool('remember_me', true);

        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Login failed. Check your credentials.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred. Please try again./N+${e}';
      _isLoading = false;
      notifyListeners();
    }
  }

  String convertToInternationalPhone(String phoneNumber) {
    // Remove all whitespaces, dashes, etc.
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');

    if (phoneNumber.startsWith('+2519')) {
      return phoneNumber; // already in correct format
    } else if (phoneNumber.startsWith('2519')) {
      return '+$phoneNumber'; // add missing +
    } else if (phoneNumber.startsWith('09')) {
      return '+251${phoneNumber.substring(1)}'; // strip leading 0 and add +251
    } else if (phoneNumber.startsWith('9') && phoneNumber.length == 9) {
      return '+251$phoneNumber'; // already without 0, just add +251
    } else {
      // fallback: invalid or unexpected format
      return phoneNumber;
    }
  }

  Future<void> logoutnew() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear stored token from SharedPreferences
    await prefs.remove('token');

    // Reset in-memory token and user
    _token = null;
    _user = null;

    // Notify UI that auth state has changed
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;

    // ✅ Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_phone');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
    await prefs.remove('token');
    await prefs.remove('user');

    await TokenStorage.clearToken();
    notifyListeners();
  }

  Future<void> loadTokenAndUser() async {
    _token = await TokenStorage.getToken();
    notifyListeners();
  }
}
