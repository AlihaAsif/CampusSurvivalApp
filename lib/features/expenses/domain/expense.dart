enum ExpenseCategory { food, transport, books, misc }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.food => 'Canteen & chai',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.books => 'Books & printing',
    ExpenseCategory.misc => 'Everything else',
  };

  int get colorValue => switch (this) {
    ExpenseCategory.food => 0xFFF2691E, // Brand Orange
    ExpenseCategory.transport => 0xFF1E2E5C, // Brand Navy
    ExpenseCategory.books => 0xFF3D5AA9, // Accent Blue
    ExpenseCategory.misc => 0xFFFA874A, // Soft Orange
  };
}

class Expense {
  final String id;
  final String title;
  final ExpenseCategory category;


  final int amountPkr;

  final DateTime spentAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amountPkr,
    required this.spentAt,
  });
}