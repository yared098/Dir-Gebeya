import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class WalletSummary {
  final double totalSales;
  final double withdrawable;
  final double onHold;
  final double withdrawn;

  WalletSummary({
    required this.totalSales,
    required this.withdrawable,
    required this.onHold,
    required this.withdrawn,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalSales: (json['total_sales'] as num).toDouble(),
      withdrawable: (json['withdrawable'] as num).toDouble(),
      onHold: (json['on_hold'] as num).toDouble(),
      withdrawn: (json['withdrawn'] as num).toDouble(),
    );
  }
}

class WalletTransaction {
  final String id;
  final double amount;
  final String comment;
  final String type;
  final String status;
  final String commissionStatus;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.comment,
    required this.type,
    required this.status,
    required this.commissionStatus,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      comment: json['comment'],
      type: json['type'],
      status: json['status'].toString(),
      commissionStatus: json['commission_status'].toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WalletProvider extends ChangeNotifier {
  WalletSummary? _summary;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  WalletSummary? get summary => _summary;
  List<WalletTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing auth token';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/wallet_api?action=summary');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("walet_provder"+data.toString());
        _summary = WalletSummary.fromJson(data);
      } else {
        _error = 'Failed to fetch wallet summary: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTransactions({String? statusFilter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing auth token';
      _isLoading = false;
      notifyListeners();
      return;
    }

    String urlString = '${ApiConfig.baseUrl}/wallet_api?action=transactions';
    if (statusFilter != null) {
      // Correct any typo 'filte' => 'filter' just in case
      final filterStatus = statusFilter.toLowerCase();
      urlString =
          '${ApiConfig.baseUrl}/wallet_api?action=filter&status=$filterStatus';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['transactions'] != null) {
          _transactions = (data['transactions'] as List)
              .map((e) => WalletTransaction.fromJson(e))
              .toList();
        } else {
          _transactions = [];
        }
      } else {
        _error = 'Failed to fetch transactions: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Send a withdrawal request
  /// [tranIds] comma separated transaction IDs
  /// [total] total amount to withdraw (string)
  /// [preferMethod] withdrawal method (e.g., "visionfund Acc")
  /// [settings] method specific settings (e.g., account number)
  /// [createdTime] formatted datetime string
  Future<bool> sendWithdrawalRequest({
    required String tranIds,
    required String total,
    required String preferMethod,
    required String settings,
    required String createdTime,
  }) async {
    _error = null;

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = 'Missing auth token';
      notifyListeners();
      return false;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/wallet_api?action=withdrawal');

    final body = {
      'tran_ids': tranIds,
      'total': total,
      'prefer_method': preferMethod,
      'settings': settings,
      'created_time': createdTime,
    };

    try {
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: body);

      if (response.statusCode == 200) {
        return true;
      } else {
        _error = 'Failed to send withdrawal request: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      notifyListeners();
      return false;
    }
  }
  Future<bool> createWithdraw({
  required String tranIds,
  required String total,
  required String preferMethod,
  required String settings,
  required String createdTime,
}) async {
  _error = null;

  final token = await TokenStorage.getToken();
  if (token == null) {
    _error = 'Missing auth token';
    notifyListeners();
    return false;
  }

  final url = Uri.parse('${ApiConfig.baseUrl}/wallet_api?action=withdrawal');

  final body = {
    'tran_ids': tranIds,
    'total': total,
    'prefer_method': preferMethod,
    'settings': settings,
    'created_time': createdTime,
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      debugPrint("Withdrawal Created: ${response.body}");
      return true;
    } else {
      _error = 'Failed to create withdrawal: ${response.statusCode}';
      debugPrint(_error!);
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = 'Error: $e';
    debugPrint(_error!);
    notifyListeners();
    return false;
  }
}

}
