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
                  onDelete: () => _showDeleteDialog(budget),
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

  void _showDeleteDialog(Budget budget) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == budget.category.toString())
        .firstOrNull;
    final categoryName = category?.name ?? 'Unknown Category';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the budget for "$categoryName"?\n\nBudget: ₹${budget.amount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BudgetProvider>().remove(budget.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Budget for "$categoryName" deleted'),
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

  String _getCategoryName(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == budget.category.toString())
        .firstOrNull;
    return category?.name ?? 'Unknown Category';
  }

  Color _getCategoryColor(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == budget.category.toString())
        .firstOrNull;
    if (category?.colorHex != null) {
      try {
        return Color(int.parse('0xFF${category!.colorHex}'));
      } catch (_) {
        return Theme.of(context).colorScheme.primary;
      }
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getCategoryIcon(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final category = categoryProvider.items
        .where((c) => c.id == budget.category.toString())
        .firstOrNull;
    if (category?.icon != null) {
      try {
        return IconData(int.parse(category!.icon!),
            fontFamily: 'MaterialIcons');
      } catch (_) {
        return Icons.account_balance_wallet;
      }
    }
    return Icons.account_balance_wallet;
  }

  String _formatDateRange() {
    final startMonth = _getMonthName(budget.startDate.month);
    final endMonth = _getMonthName(budget.endDate.month);
    final startDay = budget.startDate.day;
    final endDay = budget.endDate.day;

    if (budget.startDate.month == budget.endDate.month) {
      return '$startMonth $startDay-$endDay';
    }
    return '$startMonth $startDay - $endMonth $endDay';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(context);
    final categoryIcon = _getCategoryIcon(context);
    final categoryName = _getCategoryName(context);
    final percentageSpent = budget.percentageSpent;
    final isExceeded = budget.isExceeded;
    final isWarning = percentageSpent >= 80 && !isExceeded;

    // Determine status color
    Color statusColor;
    if (isExceeded) {
      statusColor = colorScheme.error;
    } else if (isWarning) {
      statusColor = Colors.orange;
    } else {
      statusColor = colorScheme.primary;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with category info and delete button
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateRange(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    tooltip: 'Delete budget',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Amount section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${budget.currentExpense.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'of ₹${budget.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentageSpent.toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (percentageSpent / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 12),

              // Remaining amount
              Row(
                children: [
                  Icon(
                    isExceeded ? Icons.warning_rounded : Icons.savings_outlined,
                    size: 16,
                    color: isExceeded ? colorScheme.error : colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isExceeded
                        ? 'Exceeded by ₹${(-budget.remainingAmount).toStringAsFixed(2)}'
                        : 'Remaining: ₹${budget.remainingAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isExceeded
                              ? colorScheme.error
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
