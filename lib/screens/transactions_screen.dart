import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../models/recurring_transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/account_provider.dart';
import '../widgets/transaction_form.dart';
import '../widgets/recurring_transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  static const routeName = '/transactions';

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetch();
      context.read<RecurringTransactionProvider>().fetch();
      context.read<CategoryProvider>().fetch();
      context.read<AccountProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Recurring', icon: Icon(Icons.repeat)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionProvider>().fetch();
              context.read<RecurringTransactionProvider>().fetch();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TransactionsTab(),
          _RecurringTransactionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Transaction' : 'Recurring'),
      ),
    );
  }

  void _showAddDialog() {
    if (_tabController.index == 0) {
      _showTransactionForm(null);
    } else {
      _showRecurringTransactionForm(null);
    }
  }

  void _showTransactionForm(Transaction? transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: TransactionForm(transaction: transaction),
        ),
      ),
    );
  }

  void _showRecurringTransactionForm(RecurringTransaction? transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: RecurringTransactionForm(transaction: transaction),
        ),
      ),
    );
  }
}

/// ------------------ Transactions Tab ------------------

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _ErrorView(
        message: provider.error!,
        onRetry: provider.fetch,
      );
    }

    if (provider.items.isEmpty) {
      return _EmptyView(
        message: 'No transactions yet',
        description: 'Add your first transaction to get started',
        icon: Icons.receipt_long_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final transaction = provider.items[index];
          return _TransactionCard(
            transaction: transaction,
            onEdit: () => _showTransactionForm(context, transaction),
            onDelete: () => _showDeleteDialog(context, transaction.id!),
          );
        },
      ),
    );
  }

  void _showTransactionForm(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: TransactionForm(transaction: transaction),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TransactionProvider>().remove(transactionId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// ------------------ Recurring Transactions Tab ------------------

class _RecurringTransactionsTab extends StatelessWidget {
  const _RecurringTransactionsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringTransactionProvider>();

    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _ErrorView(
        message: provider.error!,
        onRetry: provider.fetch,
      );
    }

    if (provider.items.isEmpty) {
      return _EmptyView(
        message: 'No recurring transactions yet',
        description: 'Add your first recurring transaction to automate payments',
        icon: Icons.repeat,
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetch(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final transaction = provider.items[index];
          return _RecurringTransactionCard(
            transaction: transaction,
            onEdit: () => _showRecurringTransactionForm(context, transaction),
            onDelete: () => _showDeleteDialog(context, transaction.id!),
          );
        },
      ),
    );
  }

  void _showRecurringTransactionForm(
      BuildContext context, RecurringTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: RecurringTransactionForm(transaction: transaction),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Transaction'),
        content: const Text(
          'Are you sure you want to delete this recurring transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<RecurringTransactionProvider>()
                  .remove(transactionId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recurring transaction deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// ------------------ Helper Widgets ------------------

class _EmptyView extends StatelessWidget {
  final String message;
  final String description;
  final IconData icon;

  const _EmptyView({
    required this.message,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction Card

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getCategoryName(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    return category?.name ?? 'Unknown';
  }

  String _getAccountName(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final account = accountProvider.items
        .where((a) => a.id == transaction.account.toString())
        .firstOrNull;
    return account?.name ?? 'Unknown';
  }

  Color _getCategoryColor(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    if (category?.colorHex != null) {
      try {
        return Color(int.parse('0xFF${category!.colorHex}'));
      } catch (_) {}
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getCategoryIcon(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    if (category?.icon != null) {
      try {
        return IconData(int.parse(category!.icon!),
            fontFamily: 'MaterialIcons');
      } catch (_) {}
    }
    return transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(context);
    final categoryIcon = _getCategoryIcon(context);
    final categoryName = _getCategoryName(context);
    final accountName = _getAccountName(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$accountName • ${_formatDate(transaction.date)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.isIncome
                              ? Colors.green
                              : colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.isIncome
                          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                          : colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction.type.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: transaction.isIncome
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recurring Transaction Card

class _RecurringTransactionCard extends StatelessWidget {
  const _RecurringTransactionCard({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final RecurringTransaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _getCategoryName(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    return category?.name ?? 'Unknown';
  }

  String _getAccountName(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final account = accountProvider.items
        .where((a) => a.id == transaction.account.toString())
        .firstOrNull;
    return account?.name ?? 'Unknown';
  }

  Color _getCategoryColor(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    if (category?.colorHex != null) {
      try {
        return Color(int.parse('0xFF${category!.colorHex}'));
      } catch (_) {}
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getCategoryIcon(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == transaction.category.toString())
        .firstOrNull;
    if (category?.icon != null) {
      try {
        return IconData(int.parse(category!.icon!),
            fontFamily: 'MaterialIcons');
      } catch (_) {}
    }
    return Icons.repeat;
  }

  String _formatDateRange() {
    final start = transaction.startDate;
    final end = transaction.endDate;

    String formatDate(DateTime date) {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }

    if (end == null) {
      return 'From ${formatDate(start)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(context);
    final categoryIcon = _getCategoryIcon(context);
    final categoryName = _getCategoryName(context);
    final accountName = _getAccountName(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(categoryIcon, color: categoryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat,
                                  size: 12,
                                  color: colorScheme.onTertiaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                transaction.frequencyLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            accountName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateRange(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
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
                      leading: CircleAvatar(
                        child: Text(t.isIncome ? '+' : '-'),
                      ),
                      title: Text(t.amount.toStringAsFixed(2)),
                      subtitle: Text('Category: ${t.category}\nDate: ${t.date.toLocal()}'),
                      isThreeLine: true,
                    ),
                  );
                },
              );
  }
}
