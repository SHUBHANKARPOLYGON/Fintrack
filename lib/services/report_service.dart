import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ReportService {
  Future<File> generateReport(List<Transaction> transactions, DateTime startDate, DateTime endDate) async {
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

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    // Summary section
    report.writeln('SUMMARY');
    report.writeln('-' * 40);
    report.writeln('Total Income:  ₹${totalIncome.toStringAsFixed(2)}');
    report.writeln('Total Expense: ₹${totalExpense.toStringAsFixed(2)}');
    report.writeln('Net Balance:   ₹${(totalIncome - totalExpense).toStringAsFixed(2)}');
    report.writeln();

    // Category breakdown
    report.writeln('CATEGORY BREAKDOWN');
    report.writeln('-' * 40);
    categoryTotals.forEach((category, amount) {
      report.writeln('${category.padRight(20)} ₹${amount.toStringAsFixed(2)}');
    });
    report.writeln();

    // Transaction details
    report.writeln('TRANSACTION DETAILS');
    report.writeln('-' * 40);
    report.writeln('Date'.padRight(12) + 
                   'Type'.padRight(10) + 
                   'Category'.padRight(15) + 
                   'Amount'.padRight(12) + 
                   'Description');
    report.writeln('-' * 70);

    for (var transaction in transactions) {
      report.writeln(
        '${DateFormat('MM/dd/yyyy').format(transaction.date)}'.padRight(12) +
        '${transaction.type}'.padRight(10) +
        '${transaction.category}'.padRight(15) +
        '₹${transaction.amount.toStringAsFixed(2)}'.padRight(12) +
        '${transaction.description}'
      );
    }

    // Save the report
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/expense_report.txt');
    await file.writeAsString(report.toString());
    return file;
  }
}