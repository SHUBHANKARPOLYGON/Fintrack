import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class TransactionList extends StatelessWidget {
  final String userId;
  final DatabaseService _db = DatabaseService();

  TransactionList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.getUserTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No transactions yet'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: data['type'] == 'expense' 
                    ? Colors.red 
                    : Colors.green,
                child: Icon(
                  data['type'] == 'expense' 
                      ? Icons.remove 
                      : Icons.add,
                  color: Colors.white,
                ),
              ),
              title: Text(data['category']),
              subtitle: Text(data['description'] ?? ''),
              trailing: Text(
                '₹${data['amount'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: data['type'] == 'expense' 
                      ? Colors.red 
                      : Colors.green,
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