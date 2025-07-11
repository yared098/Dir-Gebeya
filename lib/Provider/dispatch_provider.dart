import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class Dispatch {
  final int id;
  final int orderId;
  final int customerId;
  final int driverId;
  final String assignedTime;
  final String acceptedTime;
  final String pickupTime;
  final String deliveredTime;
  final String status;
  final String remarks;

  Dispatch({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.driverId,
    required this.assignedTime,
    required this.acceptedTime,
    required this.pickupTime,
    required this.deliveredTime,
    required this.status,
    required this.remarks,
  });

  factory Dispatch.fromJson(Map<String, dynamic> json) {
    return Dispatch(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      assignedTime: json['assigned_time'],
      acceptedTime: json['accepted_time'],
      pickupTime: json['pickup_time'],
      deliveredTime: json['delivered_time'],
      status: json['status'],
      remarks: json['remarks'],
    );
  }
}

class DispatchProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Dispatch> _dispatches = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Dispatch> get dispatches => _dispatches;

  Future<void> fetchDispatches({
    String status = 'assigned',
    required String dateFrom,
    required String dateTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing token';
      _isLoading = false;
      notifyListeners();
      return;
    }
    

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/dispatcher?action=list&status=$status&date_from=$dateFrom&date_to=$dateTo',
    );

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          _dispatches = data.map((e) => Dispatch.fromJson(e)).toList();
        } else {
          // empty or invalid list → use mock
          _dispatches = _getMockDispatches();
        }
      } else {
        // non-200 → error + mock
        _error = "Failed to fetch dispatch list (${response.statusCode})";
        _dispatches = _getMockDispatches();
      }
    } catch (e) {
      // exception → error + mock
      _error = "Error: $e";
      _dispatches = _getMockDispatches();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Dispatch> _getMockDispatches() {
    return [
      Dispatch(
        id: 1,
        orderId: 101,
        customerId: 201,
        driverId: 2040,
        assignedTime: '2025-06-03 10:00:00',
        acceptedTime: '2025-06-03 11:00:00',
        pickupTime: '2025-06-03 12:00:00',
        deliveredTime: '2025-06-03 13:00:00',
        status: 'assigned',
        remarks: 'Urgent delivery',
      ),
      Dispatch(
        id: 2,
        orderId: 102,
        customerId: 202,
        driverId: 2041,
        assignedTime: '2025-06-04 09:00:00',
        acceptedTime: '',
        pickupTime: '',
        deliveredTime: '',
        status: 'pending',
        remarks: 'Normal',
      ),
    ];
  }
  Future<bool> acceptDispatch({required int orderId, required String acceptedTime}) async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/dispatcher?action=accept');

    final body = {
      'order_id': orderId.toString(),
      'accepted_time': acceptedTime,
    };

    try {
      final res = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      }, body: body);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Accept error: $e");
      return false;
    }
  }

  Future<bool> updateDispatchStatus({
    required int orderId,
    required String status,
    required String time,
    required String comment,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/dispatcher?action=update-status');

    final body = {
      'order_id': orderId.toString(),
      'status': status,
      'time': time,
      'comment': comment,
    };

    try {
      final res = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      }, body: body);

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Status update error: $e");
      return false;
    }
  }



}
