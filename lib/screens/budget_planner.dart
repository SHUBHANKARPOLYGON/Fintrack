import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetPlannerScreen extends StatelessWidget {
  final String userId;

  const BudgetPlannerScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('budgets')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data!.docs;

          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets set yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index].data() as Map<String, dynamic>;
              final budgetId = budgets[index].id;  // Get the document ID
              return _buildBudgetCard(
                context: context,
                category: budget['category'],
                budget: (budget['amount'] as num).toDouble(),
                budgetId: budgetId,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (categoryController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance.collection('budgets').add({
                      'userId': userId,
                      'category': categoryController.text,
                      'amount': double.parse(budgetController.text),
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding budget: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
  Widget _buildBudgetCard({
    required BuildContext context,
    required String category, 
    required double budget,
    required String budgetId,  // Add this parameter
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Budget: ₹${budget.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmationDialog(context, budgetId, category),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String budgetId, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Budget'),
          content: Text('Are you sure you want to delete $category budget?'),
          actions: <Widget>[
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
                      .collection('budgets')
                      .doc(budgetId)
                      .delete();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$category budget deleted successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting budget: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}