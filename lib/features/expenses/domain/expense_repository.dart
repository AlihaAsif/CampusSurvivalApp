import 'expense.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);

  Stream<int> watchMonthlyBudget();
  Future<void> setMonthlyBudget(int amount);
}