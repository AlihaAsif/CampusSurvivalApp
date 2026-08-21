import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/budget_math.dart';
import '../domain/expense.dart';
import 'add_expense_screen.dart';
import 'expense_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final expensesAsync = ref.watch(expensesProvider);
    final monthList = ref.watch(monthExpensesProvider);
    final total = ref.watch(monthTotalProvider);
    final budget = ref.watch(monthlyBudgetProvider).value ?? 25000;
    final categories = ref.watch(categoryTotalsProvider);
    final weekly = ref.watch(weeklyTotalsProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final allowance = ref.watch(dailyAllowanceProvider);

    final left = budget - total;
    final daysLeft = BudgetMath.daysLeftInMonth(DateTime.now());

    final shown = selected == null
        ? monthList
        : monthList
        .where((expense) => expense.category == selected)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set budget',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => _BudgetDialog(current: budget),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
        const Center(child: Text('Could not load your expenses.')),
        data: (_) {
          if (monthList.isEmpty) {
            return _empty(theme, scheme);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              96,
            ),
            children: [
              // ---------- Summary ----------
              Card(
                color: BrandColors.navy,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent this month',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        BudgetMath.formatPkr(total),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: (total / budget).clamp(0.0, 1.0),
                          minHeight: 6,
                          color: left < 0 ? scheme.error : BrandColors.orange,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            left >= 0
                                ? '${BudgetMath.formatPkr(left)} left'
                                : '${BudgetMath.formatPkr(-left)} over',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          Text(
                            'Budget ${BudgetMath.formatPkr(budget)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: left > 0
                              ? Colors.white.withValues(alpha: 0.15)
                              : scheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          left > 0
                              ? '$daysLeft day'
                              '${daysLeft == 1 ? '' : 's'} remain. '
                              'Staying under '
                              '${BudgetMath.formatPkr(allowance)} a day '
                              'keeps you inside the budget.'
                              : 'You are ${BudgetMath.formatPkr(-left)} '
                              'over budget with $daysLeft day'
                              '${daysLeft == 1 ? '' : 's'} to go.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: left > 0
                                ? Colors.white
                                : scheme.onErrorContainer,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Donut ----------
              const SizedBox(height: AppSpacing.section),
              Text(
                'WHERE IT WENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 34,
                                startDegreeOffset: -90,
                                sections: categories.map((item) {
                                  final dimmed = selected != null &&
                                      selected != item.category;
                                  return PieChartSectionData(
                                    value: item.amount.toDouble(),
                                    radius: 16,
                                    showTitle: false,
                                    color: Color(item.category.colorValue)
                                        .withValues(
                                        alpha: dimmed ? 0.25 : 1),
                                  );
                                }).toList(),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selected == null
                                      ? '${categories.length}'
                                      : '${((categories.firstWhere((item) => item.category == selected).amount / total) * 100).round()}%',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  selected == null
                                      ? 'categories'
                                      : 'of total',
                                  style:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          children: categories.map((item) {
                            final isSelected = selected == item.category;
                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = isSelected
                                    ? null
                                    : item.category;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? scheme.surfaceContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: Color(
                                            item.category.colorValue),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        item.category.label,
                                        style: theme.textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      item.amount.toString(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Weekly bars ----------
              const SizedBox(height: AppSpacing.section),
              Text(
                'LAST 7 DAYS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPad),
                  child: SizedBox(
                    height: 120,
                    child: _WeeklyBars(data: weekly),
                  ),
                ),
              ),

              // ---------- Transactions ----------
              const SizedBox(height: AppSpacing.section),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selected == null
                        ? 'RECENT'
                        : selected.label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (selected != null)
                    TextButton(
                      onPressed: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .state = null,
                      child: const Text('Clear filter'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              ...shown.map(
                    (expense) => Padding(
                  padding:
                  const EdgeInsets.only(bottom: AppSpacing.cardGap),
                  child: _ExpenseRow(expense: expense),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }

  Widget _empty(ThemeData theme, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No expenses logged', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your first one and the charts fill in.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.data});

  final List<({String day, int amount})> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final maxAmount = data.fold<int>(
      0,
          (max, item) => item.amount > max ? item.amount : max,
    );

    return BarChart(
      BarChartData(
        maxY: (maxAmount == 0 ? 100 : maxAmount * 1.2).toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[index].day,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          final item = data[index];
          final isMax = maxAmount > 0 && item.amount == maxAmount;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.amount.toDouble(),
                width: 20,
                color: isMax ? BrandColors.orange : BrandColors.navy.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                  bottom: Radius.circular(2),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------

class _ExpenseRow extends ConsumerWidget {
  const _ExpenseRow({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onLongPress: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete expense?'),
              content: Text('"${expense.title}" will be removed.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          if (confirmed == true) {
            await ref
                .read(expenseRepositoryProvider)
                .deleteExpense(expense.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPad),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(expense.category.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      _relativeDate(expense.spentAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '−${expense.amountPkr}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;

    if (diff == 0) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour < 12 ? 'AM' : 'PM';
      return 'Today, $hour:$minute $period';
    }
    if (diff == 1) return 'Yesterday';
    return '${date.day} ${months[date.month - 1]}';
  }
}

// ---------------------------------------------------------------

class _BudgetDialog extends ConsumerStatefulWidget {
  const _BudgetDialog({required this.current});

  final int current;

  @override
  ConsumerState<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends ConsumerState<_BudgetDialog> {
  late final TextEditingController _controller =
  TextEditingController(text: widget.current.toString());

  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = int.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);

    await ref.read(expenseRepositoryProvider).setMonthlyBudget(amount);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Monthly budget'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          prefixText: 'Rs ',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}