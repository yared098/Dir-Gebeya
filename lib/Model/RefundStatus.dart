enum RefundStatus {
  Pending,
  Approved,
  Rejected,
  Processing,
}

class RefundRequest {
  final String orderId;
  final String productName;
  final String imageUrl;
  final double price;
  final String reason;
  final DateTime date;
  final RefundStatus status;

  RefundRequest({
    required this.orderId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.reason,
    required this.date,
    required this.status,
  });
}
