import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../utils/token_storage.dart';

// =========================== MODELS ===========================

class OrderDetailResponse {
  final Order order;
  final List<OrderProduct> products;
  final List<OrderHistory> history;
  final List<OrderProof> proof;

  OrderDetailResponse({
    required this.order,
    required this.products,
    required this.history,
    required this.proof,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      order: Order.fromJson(json['order']),
      products: (json['products'] as List)
          .map((e) => OrderProduct.fromJson(e))
          .toList(),
      history: (json['history'] as List)
          .map((e) => OrderHistory.fromJson(e))
          .toList(),
      proof: (json['proof'] as List)
          .map((e) => OrderProof.fromJson(e))
          .toList(),
    );
  }
}

class Order {
  final int id;
  final int status;
  final String txnId;
  final int userId;
  final String address;
  final int countryId;
  final int stateId;
  final String city;
  final String zipCode;
  final String phone;
  final String paymentMethod;
  final double shippingCost;
  final double taxCost;
  final double total;
  final double couponDiscount;
  final double totalCommission;
  final double shippingCharge;
  final String currencyCode;
  final bool allowShipping;
  final String ip;
  final String countryCode;
  final String files;
  final String? comment;
  final String createdAt;

  Order({
    required this.id,
    required this.status,
    required this.txnId,
    required this.userId,
    required this.address,
    required this.countryId,
    required this.stateId,
    required this.city,
    required this.zipCode,
    required this.phone,
    required this.paymentMethod,
    required this.shippingCost,
    required this.taxCost,
    required this.total,
    required this.couponDiscount,
    required this.totalCommission,
    required this.shippingCharge,
    required this.currencyCode,
    required this.allowShipping,
    required this.ip,
    required this.countryCode,
    required this.files,
    required this.comment,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'],
      txnId: json['txn_id'],
      userId: json['user_id'],
      address: json['address'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      city: json['city'],
      zipCode: json['zip_code'],
      phone: json['phone'],
      paymentMethod: json['payment_method'],
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      taxCost: (json['tax_cost'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      couponDiscount: (json['coupon_discount'] as num).toDouble(),
      totalCommission: (json['total_commition'] as num).toDouble(),
      shippingCharge: (json['shipping_charge'] as num).toDouble(),
      currencyCode: json['currency_code'],
      allowShipping: json['allow_shipping'] == 1,
      ip: json['ip'],
      countryCode: json['country_code'],
      files: json['files'],
      comment: json['comment'] == "null" ? null : json['comment'],
      createdAt: json['created_at'],
    );
  }
}

class OrderProduct {
  final int productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final int quantity;
  final double total;
  final Vendor vendor;
  final String profile;

  OrderProduct({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.quantity,
    required this.total,
    required this.vendor,
    required this.profile,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['product_id'],
      productName: json['product_name'],
      productImage: json['product_image'],
      productPrice: (json['product_price'] as num).toDouble(),
      quantity: json['quantity'],
      total: (json['total'] as num).toDouble(),
      vendor: Vendor.fromJson(json['vendor']),
      profile: json['profile'],
    );
  }
}

class Vendor {
  final int id;
  final String storeName;
  final String storeContact;
  final String storeEmail;

  Vendor({
    required this.id,
    required this.storeName,
    required this.storeContact,
    required this.storeEmail,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      storeName: json['store_name'],
      storeContact: json['store_contact'],
      storeEmail: json['store_email'],
    );
  }
}

class OrderHistory {
  final String historyType;
  final String paymentMode;
  final String comment;
  final String date;

  OrderHistory({
    required this.historyType,
    required this.paymentMode,
    required this.comment,
    required this.date,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      historyType: json['history_type'],
      paymentMode: json['payment_mode'],
      comment: json['comment'],
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

// =========================== PROVIDER ===========================

class OrderDetailProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  Order? _order;
  List<OrderProduct> _products = [];
  List<OrderHistory> _history = [];
  List<OrderProof> _proofs = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  Order? get order => _order;
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

    final url = Uri.parse(
      "https://direthiopia.com/api/v3/seller/order_detail_api?order_id=$orderId",
    );
    print("ord" + url.toString());
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print("order_detial" + response.body.toString());

        final data = jsonDecode(response.body);
        final parsed = OrderDetailResponse.fromJson(data);

        _order = parsed.order;
        _products = parsed.products;
        _history = parsed.history;
        _proofs = parsed.proof;
      } else {
        _error =
            "Failed to load order details. Status Code: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Network error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

 
  Future<bool> approveOrder(
    int orderId,
    String newStatus, {
    required String currentStatus, // pass the current status of the order here
    String? comment,
    String? acceptedTime,
    String? rejectedTime,
    String? pickedUpTime,
    String? deliveredTime,
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      _error = "Unauthorized";
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    Uri url;
    Map<String, dynamic> body;

    // If current status is assigned AND new status is accepted, use accept endpoint
    if (currentStatus.toLowerCase() == 'assigned' &&
        newStatus.toLowerCase() == 'accepted') {
      url = Uri.parse(
        "https://direthiopia.com/api/v3/seller/dispatcher?action=accept",
      );
      body = {
        'order_id': orderId.toString(),
        'accepted_time': acceptedTime ?? formattedTime,
      };
    } else {
      // For all other status updates (including after accepted)
      url = Uri.parse(
        "https://direthiopia.com/api/v3/seller/dispatcher?action=update-status",
      );

      // Determine the time value depending on newStatus and passed params
      String timeValue = formattedTime;
      if (newStatus.toLowerCase() == 'rejected' && rejectedTime != null) {
        timeValue = rejectedTime;
      } else if (newStatus.toLowerCase() == 'picked' && pickedUpTime != null) {
        timeValue = pickedUpTime;
      } else if (newStatus.toLowerCase() == 'delivered' &&
          deliveredTime != null) {
        timeValue = deliveredTime;
      }

      body = {
        'order_id': orderId.toString(),
        'status': newStatus.toLowerCase(),
        'time': timeValue,
        'comment': comment ?? 'from mobile app',
      };
    }
    print("new-url" + url.toString());
    print("newbody" + body.toString());

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await fetchOrderDetail(orderId); // Refresh order detail after success
        print("Response: ${response.body}");
        return true;
      } else {
        print("error body" + response.statusCode.toString());
        _error = "Approval failed: ${response.statusCode}";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Network error: $e";
      notifyListeners();
      return false;
    }
  }
}
