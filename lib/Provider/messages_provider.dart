import 'dart:convert';
import 'package:dirgebeya/Model/Messages.dart';
import 'package:dirgebeya/Pages/SheetPages/MessagesScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';  // adjust path
import '../config/api_config.dart';   // adjust path
      // import Message model here

class MessagesProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _limit = 10;
  int _totalPages = 1;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get page => _page;
  int get limit => _limit;
  int get totalPages => _totalPages;

   Future<void> fetchMessages({
    String? status,
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    // If data already loaded and no force refresh, skip fetching
    if (_messages.isNotEmpty && !forceRefresh) {
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

    final queryParameters = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (status != null) 'status': status,
    };

    final uri = Uri.https(
      'direthiopia.com',
      '/api/v3/seller/message',
      queryParameters,
    );

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        print("msg_"+response.body);
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          _messages = (data['data'] as List)
              .map((e) => Message.fromJson(e))
              .toList();
          _page = data['page'] ?? page;
          _limit = data['limit'] ?? limit;
          _totalPages = data['pages'] ?? 1;
        } else {
          _messages = [];
        }
      } else {
        _error = 'Failed to fetch messages: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markMessageAsReceived({
  required int id,
  required int userId,
}) async {
  final token = await TokenStorage.getToken();
  if (token == null) {
    _error = "Missing token";
    notifyListeners();
    return false;
  }

  final uri = Uri.https('direthiopia.com', '/api/v3/seller/message'); // same endpoint or change if needed

  final body = jsonEncode({
    "action": "mark_received",
    "id": id,
    "user_id": userId,
  });

  try {
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Optionally update the local message list if needed, e.g. mark seen or received flag
      // Find message and update it locally
      final index = _messages.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        final updatedMsg = _messages[index];
        // Assuming you want to mark received as 1 locally:
        _messages[index] = Message(
          id: updatedMsg.id,
          moduleName: updatedMsg.moduleName,
          moduleId: updatedMsg.moduleId,
          name: updatedMsg.name,
          image: updatedMsg.image,
          text: updatedMsg.text,
          seen: updatedMsg.seen,
          received: 1, // mark received
          estimation: updatedMsg.estimation,
          userId: updatedMsg.userId,
          status: updatedMsg.status,
          createdAt: updatedMsg.createdAt,
          dateCreated: updatedMsg.dateCreated,
        );
        notifyListeners();
      }

      return true;
    } else {
      _error = 'Failed to mark received: ${response.statusCode}';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = 'Error marking message as received: $e';
    notifyListeners();
    return false;
  }
}


  /// Optional: clear messages list
  void clear() {
    _messages = [];
    notifyListeners();
  }
}
