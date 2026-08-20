import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/firestore_expense_repository.dart';
import '../domain/budget_math.dart';
import '../domain/expense.dart';
import '../domain/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return FirestoreExpenseRepository(
    ref.watch(firestoreProvider),
    ref.watch(firebaseAuthProvider),
  );
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(expenseRepositoryProvider).watchExpenses();
});

final monthlyBudgetProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(25000);

  return ref.watch(expenseRepositoryProvider).watchMonthlyBudget();
});


final monthExpensesProvider = Provider<List<Expense>>((ref) {
  final all = ref.watch(expensesProvider).value ?? [];
  final now = DateTime.now();

  return all
      .where((expense) =>
  expense.spentAt.year == now.year &&
      expense.spentAt.month == now.month)
      .toList();
});

final monthTotalProvider = Provider<int>((ref) {
  final list = ref.watch(monthExpensesProvider);
  return list.fold<int>(0, (sum, expense) => sum + expense.amountPkr);
});


final categoryTotalsProvider =
Provider<List<({ExpenseCategory category, int amount})>>((ref) {
  final list = ref.watch(monthExpensesProvider);

  final totals = <ExpenseCategory, int>{};
  for (final expense in list) {
    totals[expense.category] =
        (totals[expense.category] ?? 0) + expense.amountPkr;
  }

  final result = totals.entries
      .map((entry) => (category: entry.key, amount: entry.value))
      .toList();

  result.sort((a, b) => b.amount.compareTo(a.amount));
  return result;
});


final weeklyTotalsProvider =
Provider<List<({String day, int amount})>>((ref) {
  final all = ref.watch(expensesProvider).value ?? [];
  final now = DateTime.now();
  const initials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  return List.generate(7, (index) {
    final date = now.subtract(Duration(days: 6 - index));

    final amount = all
        .where((expense) =>
    expense.spentAt.year == date.year &&
        expense.spentAt.month == date.month &&
        expense.spentAt.day == date.day)
        .fold<int>(0, (sum, expense) => sum + expense.amountPkr);

    return (day: initials[date.weekday - 1], amount: amount);
  });
});


final selectedCategoryProvider =
StateProvider<ExpenseCategory?>((ref) => null);

final dailyAllowanceProvider = Provider<int>((ref) {
  final budget = ref.watch(monthlyBudgetProvider).value ?? 25000;
  final spent = ref.watch(monthTotalProvider);
  return BudgetMath.dailyAllowance(budget, spent, DateTime.now());
});