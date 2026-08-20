class BudgetMath {
  BudgetMath._();

 
  static int dailyAllowance(int budget, int spent, DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1; // includes today
    final left = budget - spent;

    if (left <= 0 || daysLeft <= 0) return 0;
    return (left / daysLeft).floor();
  }

  static int daysLeftInMonth(DateTime now) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return daysInMonth - now.day + 1;
  }


  static String formatPkr(int amount) {
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return 'Rs ${buffer.toString()}';
  }
}