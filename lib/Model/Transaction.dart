
class Transaction {
  final String id;
  final String date;
  final double amount;
  final String status;
  final double? penalty;
  final String? comment;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.penalty,
    this.comment,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'].toString(),
      date: json['created_at'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      status: json['status'],
      comment: json['comment'] ?? '',
    );
  }

 
}
