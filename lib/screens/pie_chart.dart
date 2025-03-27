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
          
          // Define category colors
          final Map<String, Color> categoryColors = {
            'Food': Colors.orange,
            'Transportation': Colors.blue,
            'Entertainment': Colors.purple,
            'Shopping': Colors.pink,
            'Bills': Colors.red,
            'Others': Colors.grey,
          };

          // Calculate expenses by category
          Map<String, double> categoryExpenses = {
            'Food': 0,
            'Transportation': 0,
            'Entertainment': 0,
            'Shopping': 0,
            'Bills': 0,
            'Others': 0,
          };

          double totalExpenses = 0;
          double totalIncome = 0;  

          for (var doc in transactions) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['type'] == 'expense') {
              final category = data['category'] as String? ?? 'Others';
              final amount = (data['amount'] as num).toDouble();
              categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
              totalExpenses += amount;
            } else if (data['type'] == 'income') { 
              final amount = (data['amount'] as num).toDouble();
              totalIncome += amount;
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
                      sections: categoryExpenses.entries
                          .where((e) => e.value > 0) // Only show categories with expenses
                          .map((entry) {
                        final percentage = (entry.value / totalExpenses * 100);
                        return PieChartSectionData(
                          color: categoryColors[entry.key] ?? Colors.grey,
                          value: entry.value,
                          title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Category Legend
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expense Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...categoryExpenses.entries
                            .where((e) => e.value > 0)
                            .map((entry) {
                          final percentage = (entry.value / totalExpenses * 100);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: categoryColors[entry.key],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${entry.key}: ₹${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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