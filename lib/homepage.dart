import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  // Add transaction related variables
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack'),
        actions: [
          IconButton(
            onPressed: signout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '\$${_balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Transaction List
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return ListTile(
                  leading: Icon(
                    transaction['type'] == 'expense'
                        ? Icons.money_off
                        : Icons.money,
                    color: transaction['type'] == 'expense'
                        ? Colors.red
                        : Colors.green,
                  ),
                  title: Text(transaction['description']),
                  trailing: Text(
                    '\$${transaction['amount'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction['type'] == 'expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show bottom sheet to add transaction
          showModalBottomSheet(
            context: context,
            builder: (context) => AddTransactionSheet(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Add Transaction Bottom Sheet
class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Transaction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add expense logic
                },
                child: Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add income logic
                },
                child: Text('Add Income'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
