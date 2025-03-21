import 'package:fintrack/screens/bill_reminders.dart';
import 'package:fintrack/screens/budget_planner.dart';
import 'package:fintrack/screens/report_screen.dart';
import 'package:fintrack/screens/savings_goals.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_screen.dart';
import '../widgets/transaction_list.dart'; 
import '../widgets/transaction_summary.dart';
import './pie_chart.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FinTrack'),
        actions: [
          IconButton(
            icon: Icon(Icons.pie_chart), // Add pie chart icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinancialOverviewScreen(
                    userId: user?.uid ?? '',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.summarize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Transaction Summary Widget
          if (user != null) TransactionSummary(userId: user!.uid),
          
          // Transaction List
          Expanded(
            child: TransactionList(userId: user?.uid ?? ''),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Text('Navigation'),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 30, 153, 236),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Budget Planner'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetPlannerScreen(userId: user?.uid ?? ''),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('Bill Reminders'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillRemindersScreen(userId: user?.uid ?? ''),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Savings Goals'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavingsGoalsScreen(userId: user?.uid ?? ''),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}