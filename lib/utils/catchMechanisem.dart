import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> IsConnected() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}

Future<void> CacheData(String key, dynamic data) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, jsonEncode(data));
}

Future<dynamic> LoadCachedData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getString(key);
  if (cached != null) {
    return jsonDecode(cached);
  }
  return null;
}



