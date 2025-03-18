import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../models/transaction.dart';

class TransactionsTab extends StatelessWidget {
  final DatabaseService _db = DatabaseService();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getUserTransactions(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index].data() as Map<String, dynamic>;
            final amount = transaction['amount'] as double;
            final isExpense = transaction['type'] == 'expense';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isExpense ? Colors.red : Colors.green,
                child: Icon(
                  isExpense ? Icons.remove : Icons.add,
                  color: Colors.white,
                ),
              ),
              title: Text(transaction['category']),
              subtitle: Text(transaction['description']),
              trailing: Text(
                '${isExpense ? '-' : '+'}₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}