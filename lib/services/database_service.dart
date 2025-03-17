import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart' as fintrack;
import '../models/budget.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add transaction
  Future<void> addTransaction(fintrack.Transaction transaction) async {
    await _db.collection('transactions').add(transaction.toMap());
  }

  // Get user transactions
  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _db
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Add budget
  Future<void> addBudget(Budget budget) async {
    await _db.collection('budgets').add(budget.toMap());
  }

  // Get user budgets
  Stream<QuerySnapshot> getUserBudgets(String userId) {
    return _db
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }
}