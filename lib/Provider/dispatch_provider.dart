import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../utils/token_storage.dart';
class Dispatch {
  final int id;
  final int orderId;
  final int customerId;
  final int driverId;
  final DateTime? assignedTime;
  final DateTime? acceptedTime;
  final DateTime? pickupTime;
  final DateTime? deliveredTime;
  final String status;
  final String remarks;

  Dispatch({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.driverId,
    this.assignedTime,
    this.acceptedTime,
    this.pickupTime,
    this.deliveredTime,
    required this.status,
    required this.remarks,
  });

  factory Dispatch.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      try {
        return DateTime.parse(date.toString());
      } catch (_) {
        return null;
      }
    }

    return Dispatch(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      assignedTime: parseDate(json['assigned_time']),
      acceptedTime: parseDate(json['accepted_time']),
      pickupTime: parseDate(json['pickup_time']),
      deliveredTime: parseDate(json['delivered_time']),
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'customer_id': customerId,
        'driver_id': driverId,
        'assigned_time': assignedTime?.toIso8601String(),
        'accepted_time': acceptedTime?.toIso8601String(),
        'pickup_time': pickupTime?.toIso8601String(),
        'delivered_time': deliveredTime?.toIso8601String(),
        'status': status,
        'remarks': remarks,
      };
}



class DispatchProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Dispatch> _dispatches = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Dispatch> get dispatches => _dispatches;
  
  Future<void> fetchDispatches({required String status}) async {
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

    // Format dates as yyyy-MM-dd
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime now = DateTime.now();
    final String dateTo = formatter.format(now);
    final String dateFrom = formatter.format(now.subtract(Duration(days: 3)));

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
        print("disp url" + url.toString());
        print("disp: $data");

        if (data is List && data.isNotEmpty) {
          _dispatches = data.map((e) => Dispatch.fromJson(e)).toList();
        } else {
          
        }
      } else {
        print("hello world");
        _error = "Failed to fetch dispatch list (${response.statusCode})";
        
      }
    } catch (e) {
      _error = "Error: $e";
      
    }

    _isLoading = false;
    notifyListeners();
  }

 
  Future<bool> acceptDispatch({
    required int orderId,
    required String acceptedTime,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;

    final url = Uri.parse('${ApiConfig.baseUrl}/dispatcher?action=accept');

    final body = {
      'order_id': orderId.toString(),
      'accepted_time': acceptedTime,
    };

    try {
      final res = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

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

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/dispatcher?action=update-status',
    );

    final body = {
      'order_id': orderId.toString(),
      'status': status,
      'time': time,
      'comment': comment,
    };

    try {
      final res = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Status update error: $e");
      return false;
    }
  }
}
