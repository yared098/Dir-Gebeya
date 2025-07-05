import 'dart:convert';
import 'package:dirgebeya/Model/userModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        body: {
          'phone': phone,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);

        // Save token securely
        await TokenStorage.saveToken(_token!);

        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Login failed. Check your credentials.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'An error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await TokenStorage.clearToken();
    notifyListeners();
  }

  Future<void> loadTokenAndUser() async {
    _token = await TokenStorage.getToken();
    // If needed: fetch user info again with token
    notifyListeners();
  }
}
