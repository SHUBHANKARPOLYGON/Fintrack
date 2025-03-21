import 'package:flutter/material.dart';

class BillRemindersScreen extends StatelessWidget {
  final String userId;

  const BillRemindersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildReminderCard({required String billName, required DateTime dueDate, required double amount}) {
      return Card(
        child: ListTile(
          title: Text(billName),
          subtitle: Text('Due: ${dueDate.toLocal()}'),
          trailing: Text('\$$amount'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminders'),
      ),
      body: ListView(
        children: [
          _buildReminderCard(
            billName: 'Electricity Bill',
            dueDate: DateTime.now().add(const Duration(days: 7)),
            amount: 2000,
          ),
          // Add more reminder cards
        ],
      ),
    );
  }
}