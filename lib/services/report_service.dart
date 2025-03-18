import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart' as fintrack;

class ReportService {
  Future<File> generateReport(List<fintrack.Transaction> transactions, DateTime startDate, DateTime endDate) async {
    try {
      final StringBuffer report = StringBuffer();
      
      // Report header
      report.writeln('FINTRACK EXPENSE REPORT');
      report.writeln('=' * 40);
      report.writeln('Period: ${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}');
      report.writeln('=' * 40);
      report.writeln();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> categoryTotals = {};

      // Process transactions
      for (var transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
          categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        }
      }

      // Write summary
      report.writeln('SUMMARY');
      report.writeln('-' * 40);
      report.writeln('Total Income:  ₹${totalIncome.toStringAsFixed(2)}');
      report.writeln('Total Expense: ₹${totalExpense.toStringAsFixed(2)}');
      report.writeln('Net Balance:   ₹${(totalIncome - totalExpense).toStringAsFixed(2)}');
      report.writeln();

      // Write transactions
      report.writeln('TRANSACTIONS');
      report.writeln('-' * 40);
      report.writeln('Date       Type     Category      Amount     Description');
      report.writeln('-' * 70);

      for (var transaction in transactions) {
        final date = DateFormat('yyyy-MM-dd').format(transaction.date);
        final type = transaction.type.padRight(8);
        final category = transaction.category.padRight(12);
        final amount = '₹${transaction.amount.toStringAsFixed(2)}'.padRight(10);
        
        report.writeln('$date $type $category $amount ${transaction.description}');
      }

      // Save report to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_report_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(report.toString());
      return file;

    } catch (e) {
      print('Error generating report: $e');
      rethrow;
    }
  }
}