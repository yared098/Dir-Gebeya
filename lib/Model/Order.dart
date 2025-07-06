// order.dart

enum OrderStatus { Delivered, Pending, Cancelled }

enum PaymentMethod { COD, Wallet, CreditCard }

class Order {
  final String id;
  final String date;
  final String amount;
  final OrderStatus status;
  final PaymentMethod paymentMethod;

  Order({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.paymentMethod,
  });

  // Optional: Add fromJson/toJson if you're working with API
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      date: json['date'],
      amount: json['amount'],
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['status'].toLowerCase(),
        orElse: () => OrderStatus.Pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['paymentMethod'].toLowerCase(),
        orElse: () => PaymentMethod.COD,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'amount': amount,
        'status': status.toString().split('.').last,
        'paymentMethod': paymentMethod.toString().split('.').last,
      };
}
