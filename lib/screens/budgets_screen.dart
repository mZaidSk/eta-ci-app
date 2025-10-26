import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../models/budget.dart';
import '../widgets/budget_form.dart';
import '../providers/budget_provider.dart'; // Import your BudgetProvider

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  static const routeName = '/budgets';

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetch(); // For category dropdown
      context.read<BudgetProvider>().fetch(); // Fetch budgets
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Budgets'),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            tooltip: 'Add Budget',
            icon: const Icon(Icons.add),
            onPressed: () => _showBudgetForm(null),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              categoryProvider.fetch();
              budgetProvider.fetch();
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (budgetProvider.isLoading && budgetProvider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.error != null) {
            return _ErrorView(
              message: budgetProvider.error!,
              onRetry: budgetProvider.fetch,
            );
          }

          final budgets = budgetProvider.items;

          if (budgets.isEmpty) {
            return _EmptyView(onAdd: () => _showBudgetForm(null));
          }

          return RefreshIndicator(
            onRefresh: budgetProvider.fetch,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return _BudgetCard(
                  budget: budget,
                  onEdit: () => _showBudgetForm(budget),
                  onDelete: () {
                    // Implement delete logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted budget ${budget.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showBudgetForm(Budget? budget) {
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
        initialChildSize: 0.7,
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
          child: BudgetForm(budget: budget),
        ),
      ),
    );
  }
}

/// ------------------ Helper Widgets ------------------

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money_outlined,
                size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No Budgets Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first budget to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Budget'),
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
              'Error loading budgets',
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onEdit,
        title: Text('Budget Limit: \$${budget.amount}'),
        subtitle: Text('Category: ${budget.categoryId}'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
