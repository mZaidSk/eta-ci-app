import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  int? _selectedAccount;
  int? _selectedCategory;
  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );

    if (widget.transaction != null) {
      _selectedAccount = widget.transaction!.account;
      _selectedCategory = widget.transaction!.category;
      _selectedType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccount == null) {
      _showError('Please select an account');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isSubmitting = true);

    final transaction = Transaction(
      id: widget.transaction?.id,
      account: _selectedAccount!,
      category: _selectedCategory!,
      type: _selectedType,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      date: _selectedDate,
    );

    final provider = context.read<TransactionProvider>();
    final success = widget.transaction == null
        ? await provider.create(transaction)
        : await provider.update(widget.transaction!.id!, transaction);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.transaction == null
                ? 'Transaction created successfully'
                : 'Transaction updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showError(provider.error ?? 'Failed to save transaction');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accountProvider = context.watch<AccountProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    // Filter categories by selected type
    final filteredCategories = categoryProvider.items
        .where((c) => c.type.toLowerCase() == _selectedType.toLowerCase())
        .toList();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                widget.transaction == null
                    ? 'New Transaction'
                    : 'Edit Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Type selector (Income/Expense)
          Text(
            'Type',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTypeButton('Income', Icons.arrow_downward),
                _buildTypeButton('Expense', Icons.arrow_upward),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Amount field
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account dropdown
          DropdownButtonFormField<int>(
            value: _selectedAccount,
            decoration: InputDecoration(
              labelText: 'Account',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.account_balance_wallet),
            ),
            items: accountProvider.items.map((account) {
              return DropdownMenuItem(
                value: int.tryParse(account.id) ?? 0,
                child: Text(account.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedAccount = value),
            validator: (value) =>
                value == null ? 'Please select an account' : null,
          ),
          const SizedBox(height: 16),

          // Category dropdown
          DropdownButtonFormField<int>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: filteredCategories.map((category) {
              return DropdownMenuItem(
                value: int.tryParse(category.id) ?? 0,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 16),

          // Date picker
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description field
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.transaction == null
                          ? 'Create Transaction'
                          : 'Update Transaction',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String type, IconData icon) {
    final isSelected = _selectedType.toLowerCase() == type.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() {
            _selectedType = type.toLowerCase();
            _selectedCategory = null; // Reset category when type changes
          }),
          splashColor: colorScheme.primary.withValues(alpha: 0.2),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
