import 'package:flutter/material.dart';

class SavingsGoalsScreen extends StatelessWidget {
  final String userId;

  const SavingsGoalsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: ListView(
        children: [
          _buildGoalCard(
            goalName: 'New Laptop',
            targetAmount: 80000,
            savedAmount: 45000,
            targetDate: DateTime(2024, 12, 31),
          ),
          // Add more goal cards
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String goalName,
    required int targetAmount,
    required int savedAmount,
    required DateTime targetDate,
  }) {
    return Card(
      child: ListTile(
        title: Text(goalName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Amount: \$${targetAmount.toString()}'),
            Text('Saved Amount: \$${savedAmount.toString()}'),
            Text('Target Date: ${targetDate.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}