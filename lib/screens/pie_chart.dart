import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialOverviewScreen extends StatelessWidget {
  final String userId;

  const FinancialOverviewScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs;
          
          // Calculate total income and expenses
          double totalIncome = 0;
          double totalExpenses = 0;

          for (var doc in transactions) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['type'] == 'income') {
              totalIncome += (data['amount'] as num).toDouble();
            } else if (data['type'] == 'expense') {
              totalExpenses += (data['amount'] as num).toDouble();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        if (totalIncome > 0)
                          PieChartSectionData(
                            color: Colors.green,
                            value: totalIncome,
                            title: 'Income\n₹${totalIncome.toStringAsFixed(2)}',
                            radius: 100,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (totalExpenses > 0)
                          PieChartSectionData(
                            color: Colors.red,
                            value: totalExpenses,
                            title: 'Expenses\n₹${totalExpenses.toStringAsFixed(2)}',
                            radius: 100,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Financial Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Total Income: ₹${totalIncome.toStringAsFixed(2)}'),
                        Text('Total Expenses: ₹${totalExpenses.toStringAsFixed(2)}'),
                        Text(
                          'Net Balance: ₹${(totalIncome - totalExpenses).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: totalIncome - totalExpenses >= 0 
                              ? Colors.green 
                              : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personalized Savings Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Dynamic tips based on financial situation
                        if (totalExpenses > totalIncome)
                          const Text(
                            '⚠️ Alert: Spending exceeds income!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 8),
                        // General savings tips
                        _buildTipItem('📱 Review and cancel unused subscriptions'),
                        _buildTipItem('🛒 Make a shopping list and stick to it'),
                        _buildTipItem('🍱 Cook meals at home instead of eating out'),
                        _buildTipItem('💰 Set aside 20% of income for savings'),
                        if (totalExpenses > 0.7 * totalIncome)
                          _buildTipItem(
                            '⚡ Try to reduce monthly expenses by finding better utility plans',
                            isImportant: true,
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'Monthly Overview:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Savings Rate: ${(totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome * 100).toStringAsFixed(1) : '0')}%',
                          style: TextStyle(
                            color: (totalIncome - totalExpenses) >= 0.2 * totalIncome
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipItem(String tip, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: isImportant ? Colors.red : Colors.black87,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}