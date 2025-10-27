import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';

class BudgetForm extends StatefulWidget {
  final Budget? budget;
  const BudgetForm({super.key, this.budget});

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCategory;
  late TextEditingController _amountController;
  late TextEditingController _currentExpenseController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.budget?.amount.toString() ?? '');
    _currentExpenseController = TextEditingController(
        text: widget.budget?.currentExpense.toString() ?? '0.00');

    // Safely parse category ID
    _selectedCategory = widget.budget?.category;

    _startDate = widget.budget != null
        ? DateTime.tryParse(widget.budget!.startDate.toString())
        : DateTime.now();
    _endDate = widget.budget != null
        ? DateTime.tryParse(widget.budget!.endDate.toString())
        : DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currentExpenseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate! : _endDate!;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final newBudget = Budget(
      id: widget.budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory ?? 0,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      currentExpense: double.tryParse(_currentExpenseController.text) ?? 0.0,
      startDate: _startDate!,
      endDate: _endDate!,
    );

    // Save using provider
    final budgetProvider = context.read<BudgetProvider>();
    if (widget.budget != null) {
      budgetProvider.update(newBudget);
    } else {
      budgetProvider.add(newBudget);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.items;
    // 2. Get the loading and error states (assuming they exist)
    final isLoadingCategories = categoryProvider.isLoading;
    final categoryError = categoryProvider.error;

    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.budget != null;

// Ensure _selectedCategory is valid (this logic is fine)
    if (!isLoadingCategories && categoryError == null) {
      if (_selectedCategory != null &&
          !categories
              .any((c) => int.tryParse(c.id.toString()) == _selectedCategory)) {
        _selectedCategory = null;
      }
    }
    // Ensure _selectedCategory is valid
    if (_selectedCategory != null &&
        !categories
            .any((c) => int.tryParse(c.id.toString()) == _selectedCategory)) {
      _selectedCategory = null;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  isEditing ? 'Edit Budget' : 'New Budget',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  Text(
                    'Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  // 3. Add UI for loading, error, and empty states
                  if (isLoadingCategories)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (categoryError != null)
                    Text(
                      'Error: $categoryError',
                      style: TextStyle(color: colorScheme.error),
                    )
                  else if (categories.isEmpty)
                    const Text('No categories found.')
                  else
                    DropdownButtonFormField<int>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      items: categories
                          .map((Category category) {
                            final id = int.tryParse(category.id.toString());
                            if (id == null) return null;
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(category.name),
                            );
                          })
                          .where((item) => item != null)
                          .cast<DropdownMenuItem<int>>()
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      validator: (val) =>
                          val == null ? 'Please select a category' : null,
                    ),

                  const SizedBox(height: 16),

                  // Amount
                  Text(
                    'Amount',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 16),

                  // Current Expense
                  Text(
                    'Current Expense',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentExpenseController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLowest,
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),

                  // Start Date
                  Text(
                    'Start Date',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _pickDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      child: Text(
                        _startDate != null
                            ? _startDate!.toIso8601String().split('T').first
                            : 'Select date',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // End Date
                  Text(
                    'End Date',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _pickDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      child: Text(
                        _endDate != null
                            ? _endDate!.toIso8601String().split('T').first
                            : 'Select date',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saveForm,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(isEditing ? 'Update' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
