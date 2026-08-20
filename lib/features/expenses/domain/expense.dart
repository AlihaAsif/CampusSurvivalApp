enum ExpenseCategory { food, transport, books, misc }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.food => 'Canteen & chai',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.books => 'Books & printing',
    ExpenseCategory.misc => 'Everything else',
  };

  int get colorValue => switch (this) {
    ExpenseCategory.food => 0xFF3D5AA9,
    ExpenseCategory.transport => 0xFF1F6683,
    ExpenseCategory.books => 0xFF8A5300,
    ExpenseCategory.misc => 0xFF725572,
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