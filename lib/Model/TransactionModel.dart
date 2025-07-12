enum TransactionStatus { All, Paid, Upcaming,Due}

class Transaction {
  final String id;
  final String date;
  final String amount;
  final TransactionStatus status;
  final String? penalty;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.penalty,
  });
}
