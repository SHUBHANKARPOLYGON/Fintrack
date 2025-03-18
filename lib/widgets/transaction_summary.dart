import 'package:flutter/material.dart';
import '../services/database_service.dart';

class TransactionSummary extends StatelessWidget {
  final String userId;
  final DatabaseService _db = DatabaseService();

  TransactionSummary({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _db.getUserTransactions(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        double totalIncome = 0;
        double totalExpense = 0;

        snapshot.data!.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['type'] == 'income') {
            totalIncome += data['amount'];
          } else {
            totalExpense += data['amount'];
          }
        });

        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Monthly Summary',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Income',
                      amount: totalIncome,
                      color: Colors.green,
                    ),
                    _SummaryItem(
                      label: 'Expense',
                      amount: totalExpense,
                      color: Colors.red,
                    ),
                    _SummaryItem(
                      label: 'Balance',
                      amount: totalIncome - totalExpense,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}