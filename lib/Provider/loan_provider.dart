import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class Loan {
  final int loanId;
  final String month;
  final String amount;
  final String dueDate;
  final String status;
  final String comment;
  final String penalty;

  Loan({
    required this.loanId,
    required this.month,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.comment,
    required this.penalty,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      loanId: json['loan_id'],
      month: json['month'],
      amount: json['amount'],
      dueDate: json['due_date'],
      status: json['status'],
      comment: json['comment'],
      penalty: json['penalty'],
    );
  }
}

class LoanProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String _filter = 'all';
  List<Loan> _loans = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Loan> get loans => _loans;
  String get filter => _filter;

  Future<void> fetchLoans({String filter = 'all'}) async {
    _isLoading = true;
    _error = null;
    _filter = filter;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Unauthorized: Missing token";
      _isLoading = false;
      notifyListeners();
      return;
    }

    String endpoint = '/loan_api';
    if (filter != 'all') {
      endpoint = '/get_driver_loans?filter=$filter';
    }

    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("rsp_load"+response.body);
        if (data['status'] == 'success' && data['loans'] is List) {
          _loans = (data['loans'] as List)
              .map((loan) => Loan.fromJson(loan))
              .toList();
        } else {
          _error = "Unexpected response format";
        }
      } else {
        _error = "Failed to fetch loans (Code: ${response.statusCode})";
      }
    } catch (e) {
      _error = "Error fetching loan data: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
