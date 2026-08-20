import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/expense.dart';
import '../domain/expense_repository.dart';

class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _userDoc.collection('expenses');

  @override
  Stream<List<Expense>> watchExpenses() {
    return _collection.orderBy('spentAt', descending: true).snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Expense(
            id: doc.id,
            title: data['title'] as String? ?? '',
            category: _toCategory(data['category'] as String?),
            amountPkr: data['amountPkr'] as int? ?? 0,
            spentAt:
            (data['spentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      },
    );
  }

  @override
  Future<void> addExpense(Expense expense) {
    return _collection.add({
      'title': expense.title.trim(),
      'category': expense.category.name,
      'amountPkr': expense.amountPkr,
      'spentAt': Timestamp.fromDate(expense.spentAt),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteExpense(String expenseId) {
    return _collection.doc(expenseId).delete();
  }

  @override
  Stream<int> watchMonthlyBudget() {
    return _userDoc.snapshots().map(
          (snapshot) => snapshot.data()?['monthlyBudget'] as int? ?? 25000,
    );
  }

  @override
  Future<void> setMonthlyBudget(int amount) {
    return _userDoc.set(
      {'monthlyBudget': amount},
      SetOptions(merge: true),
    );
  }

  ExpenseCategory _toCategory(String? value) {
    return ExpenseCategory.values.firstWhere(
          (category) => category.name == value,
      orElse: () => ExpenseCategory.misc,
    );
  }
}