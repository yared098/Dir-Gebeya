import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/token_storage.dart';

class OrderDetail {
  final int id;
  final String address;
  final String city;
  final String phone;
  final String paymentMethod;
  final double tax;
  final double total;
  final String createdAt;

  OrderDetail({
    required this.id,
    required this.address,
    required this.city,
    required this.phone,
    required this.paymentMethod,
    required this.tax,
    required this.total,
    required this.createdAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      address: json['address'],
      city: json['city'],
      phone: json['phone'],
      paymentMethod: json['payment_method'],
      tax: (json['tax_cost'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class OrderProduct {
  final int productId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final double total;
  final String storeName;
  final String storeContact;
  final String storeEmail;

  OrderProduct({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.total,
    required this.storeName,
    required this.storeContact,
    required this.storeEmail,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['product_id'],
      name: json['product_name'],
      image: json['product_image'],
      price: (json['product_price'] as num).toDouble(),
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
      storeName: json['vendor']['store_name'],
      storeContact: json['vendor']['store_contact'],
      storeEmail: json['vendor']['store_email'],
    );
  }
}

class OrderHistory {
  final String type;
  final String paymentMode;
  final String comment;
  final String date;

  OrderHistory({
    required this.type,
    required this.paymentMode,
    required this.comment,
    required this.date,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      type: json['history_type'],
      paymentMode: json['payment_mode'],
      comment: json['comment'] ?? '',
      date: json['date'],
    );
  }
}

class OrderProof {
  final String file;

  OrderProof({required this.file});

  factory OrderProof.fromJson(Map<String, dynamic> json) {
    return OrderProof(file: json['file']);
  }
}

class OrderDetailProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  OrderDetail? _order;
  List<OrderProduct> _products = [];
  List<OrderHistory> _history = [];
  List<OrderProof> _proofs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderDetail? get order => _order;
  List<OrderProduct> get products => _products;
  List<OrderHistory> get history => _history;
  List<OrderProof> get proofs => _proofs;

  Future<void> fetchOrderDetail(int orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Unauthorized";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse("${ApiConfig.orderDetail}/?order_id=$orderId");

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _order = OrderDetail.fromJson(data['order']);

        _products = (data['products'] as List)
            .map((p) => OrderProduct.fromJson(p))
            .toList();

        _history = (data['history'] as List)
            .map((h) => OrderHistory.fromJson(h))
            .toList();

        _proofs = (data['proof'] as List)
            .map((p) => OrderProof.fromJson(p))
            .toList();
      } else {
        _error = "Failed to load order details.";
      }
    } catch (e) {
      _error = "An error occurred: $e";
    }

    _isLoading = false;
    notifyListeners();
  }
}
