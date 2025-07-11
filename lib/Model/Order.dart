class Order {
  final int orderId;
  final String paymentMode;
  final double amount;
  final double tax;
  final String status;
  final String date;

  Order({
    required this.orderId,
    required this.paymentMode,
    required this.amount,
    required this.tax,
    required this.status,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Convert "null" string or null to empty string
    String statusStr = (json['status'] == null || json['status'] == "null") ? '' : json['status'].toString();

    return Order(
      orderId: json['order_id'] ?? 0,
      paymentMode: json['payment_mode'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      status: statusStr,
      date: json['date'] ?? '',
    );
  }
}