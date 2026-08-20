import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/expense.dart';
import 'expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.food;
  DateTime _spentAt = DateTime.now();

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _spentAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      _spentAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _spentAt.hour,
        _spentAt.minute,
      );
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(expenseRepositoryProvider).addExpense(
        Expense(
          id: '',
          title: _titleController.text,
          category: _category,
          amountPkr: int.parse(_amountController.text.trim()),
          spentAt: _spentAt,
        ),
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenH),
          children: [
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'What did you spend on?',
                hintText: 'Paratha and doodh patti',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return 'Enter a title';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Rs ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Enter the amount';
                final amount = int.tryParse(text);
                if (amount == null) return 'Whole rupees only';
                if (amount <= 0) return 'Must be more than zero';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Category',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ExpenseCategory.values.map((category) {
                return ChoiceChip(
                  label: Text(category.label),
                  selected: _category == category,
                  avatar: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(category.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onSelected: (_) => setState(() => _category = category),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.lg),

            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${_spentAt.day}/${_spentAt.month}/${_spentAt.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child:
                  CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Save expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}