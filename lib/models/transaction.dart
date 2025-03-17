class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.type,
    required this.date, required String category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['userId'],
      amount: map['amount'],
      description: map['description'],
      type: map['type'],
      date: DateTime.parse(map['date']), category: '',
    );
  }
}