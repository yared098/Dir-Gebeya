enum TransactionStatus { Approved, Pending, Denied }

class Transaction {
  final String id;
  final String date;
  final String amount;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
  });
}