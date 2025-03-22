import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillRemindersScreen extends StatefulWidget {
  final String userId;

  const BillRemindersScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BillRemindersScreen> createState() => _BillRemindersScreenState();
}

class _BillRemindersScreenState extends State<BillRemindersScreen> {
  Widget _buildReminderCard({
    required String billName,
    required DateTime dueDate,
    required double amount,
    required String billId,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          billName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Due: ${dueDate.toString().split(' ')[0]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(billId, billName),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillDialog() {
    final billNameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Bill Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: billNameController,
                decoration: const InputDecoration(labelText: 'Bill Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
                child: const Text('Select Due Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (billNameController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('bills').add({
                      'userId': widget.userId,
                      'billName': billNameController.text,
                      'amount': double.parse(amountController.text),
                      'dueDate': selectedDate,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding bill: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String billId, String billName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Bill Reminder'),
          content: Text('Are you sure you want to delete $billName reminder?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('bills')
                      .doc(billId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting bill: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bills')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bills = snapshot.data!.docs;

          if (bills.isEmpty) {
            return const Center(child: Text('No bill reminders yet'));
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index].data() as Map<String, dynamic>;
              return _buildReminderCard(
                billName: bill['billName'],
                dueDate: (bill['dueDate'] as Timestamp).toDate(),
                amount: (bill['amount'] as num).toDouble(),
                billId: bills[index].id,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBillDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}