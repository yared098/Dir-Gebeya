class OrderDetail {
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

  OrderDetail({
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

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['order_id'],
      customerId: json['customer_id'],
      driverId: json['driver_id'],
      assignedTime: json['assigned_time'] ?? '',
      acceptedTime: json['accepted_time'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
      deliveredTime: json['delivered_time'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }
}
