import 'package:fintrack/models/transaction.dart';

class FinancialData {
  final double amount;
  final String category;
  final String type; // 'income' or 'expense'
  final DateTime date;

  FinancialData({
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  static fromTransaction(Transaction transaction) {}
}