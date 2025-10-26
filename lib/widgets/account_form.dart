import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../providers/account_provider.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({super.key, this.account});

  final Account? account;

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedAccountType = 'savings';

  final List<String> _accountTypes = ['savings', 'checking', 'credit', 'investment'];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _selectedAccountType = widget.account!.accountType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isEditing ? 'Edit Account' : 'Add New Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., My Salary Account',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an account name';
                    }
                    if (value.trim().length < 3) {
                      return 'Account name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountType,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _accountTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getAccountTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an account type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Balance',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a balance';
                    }
                    final balance = double.tryParse(value.trim());
                    if (balance == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AccountProvider>(
                  builder: (context, provider, child) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveAccount,
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update Account' : 'Add Account'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAccountTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'checking':
        return 'Checking Account';
      case 'credit':
        return 'Credit Card';
      case 'investment':
        return 'Investment Account';
      default:
        return type;
    }
  }

  void _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AccountProvider>();
    final name = _nameController.text.trim();
    final balance = double.parse(_balanceController.text.trim());
    
    final account = Account(
      id: widget.account?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      accountType: _selectedAccountType,
      balance: balance,
    );

    try {
      if (widget.account != null) {
        await provider.update(account);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account "$name" updated successfully')),
          );
        }
      } else {
        await provider.add(account);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account "$name" added successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error ?? e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
