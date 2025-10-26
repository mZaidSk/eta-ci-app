import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  static const routeName = '/transactions';

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.items.length,
                  itemBuilder: (_, i) {
                    final t = provider.items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(t.amount >= 0 ? '+' : '-'),
                        ),
                        title: Text(t.amount.toStringAsFixed(2)),
                        subtitle: Text('Category: ${t.categoryId}\nDate: ${t.date.toLocal()}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

class TransactionsScreenBody extends StatelessWidget {
  const TransactionsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Mirror of TransactionsScreen content but without Scaffold
    final provider = context.watch<TransactionProvider>();
    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : provider.error != null
            ? Center(child: Text(provider.error!))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.items.length,
                itemBuilder: (_, i) {
                  final t = provider.items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(t.amount >= 0 ? '+' : '-')),
                      title: Text(t.amount.toStringAsFixed(2)),
                      subtitle: Text('Category: ${t.categoryId}\nDate: ${t.date.toLocal()}'),
                      isThreeLine: true,
                    ),
                  );
                },
              );
  }
}

