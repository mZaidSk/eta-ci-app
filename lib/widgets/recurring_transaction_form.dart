import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recurring_transaction.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';

class RecurringTransactionForm extends StatefulWidget {
  const RecurringTransactionForm({super.key, this.transaction});

  final RecurringTransaction? transaction;

  @override
  State<RecurringTransactionForm> createState() =>
      _RecurringTransactionFormState();
}

class _RecurringTransactionFormState extends State<RecurringTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  int? _selectedAccount;
  int? _selectedCategory;
  String _selectedFrequency = 'monthly';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSubmitting = false;

  final List<Map<String, String>> _frequencies = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

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
      _selectedFrequency = widget.transaction!.frequency;
      _startDate = widget.transaction!.startDate;
      _endDate = widget.transaction!.endDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
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

    final transaction = RecurringTransaction(
      id: widget.transaction?.id,
      account: _selectedAccount!,
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      frequency: _selectedFrequency,
      startDate: _startDate,
      endDate: _endDate,
    );

    final provider = context.read<RecurringTransactionProvider>();
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
                ? 'Recurring transaction created successfully'
                : 'Recurring transaction updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      _showError(provider.error ?? 'Failed to save recurring transaction');
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
                    ? 'New Recurring Transaction'
                    : 'Edit Recurring Transaction',
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
            items: categoryProvider.items.map((category) {
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

          // Frequency dropdown
          DropdownButtonFormField<String>(
            value: _selectedFrequency,
            decoration: InputDecoration(
              labelText: 'Frequency',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.repeat),
            ),
            items: _frequencies.map((freq) {
              return DropdownMenuItem(
                value: freq['value'],
                child: Text(freq['label']!),
              );
            }).toList(),
            onChanged: (value) =>
                setState(() => _selectedFrequency = value ?? 'monthly'),
          ),
          const SizedBox(height: 16),

          // Start Date picker
          InkWell(
            onTap: _pickStartDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              child: Text(
                '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // End Date picker (optional)
          InkWell(
            onTap: _pickEndDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'End Date (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event),
                suffixIcon: _endDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endDate = null),
                      )
                    : null,
              ),
              child: Text(
                _endDate != null
                    ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                    : 'No end date',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _endDate == null
                          ? colorScheme.onSurfaceVariant
                          : null,
                    ),
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
                          ? 'Create Recurring Transaction'
                          : 'Update Recurring Transaction',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
