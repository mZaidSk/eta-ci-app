import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../models/category.dart';
import '../widgets/category_form.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  static const routeName = '/categories';

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // 0 => Income (default), 1 => Expense
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    // Filter categories by selected tab
    final selectedType = _selectedIndex == 0 ? 'income' : 'expense';
    final filteredItems = provider.items
        .where((c) => c.type.toLowerCase() == selectedType)
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('All Categories'),
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildToggleButton(
                    label: 'Income',
                    isSelected: _selectedIndex == 0,
                    colorScheme: colorScheme,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _buildToggleButton(
                    label: 'Expense',
                    isSelected: _selectedIndex == 1,
                    colorScheme: colorScheme,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryForm(null),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetch(),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _ErrorView(
              message: provider.error!,
              onRetry: provider.fetch,
            );
          }

          if (filteredItems.isEmpty) {
            return _EmptyView(onAdd: () => _showCategoryForm(null));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetch(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final category = filteredItems[index];
                return _ModernCategoryCard(
                  category: category,
                  onEdit: () => _showCategoryForm(category),
                  onDelete: () => _showDeleteDialog(category),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          splashColor: colorScheme.primary.withOpacity(0.2),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryForm(Category? category) {
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
          child: CategoryForm(category: category),
        ),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<CategoryProvider>().remove(category.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category "${category.name}" deleted'),
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
            Icon(Icons.category_outlined, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No Categories Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first category to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
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
              'Error loading categories',
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

class _ModernCategoryCard extends StatelessWidget {
  const _ModernCategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return Colors.blue;
    try {
      return Color(int.parse('0xFF$colorHex'));
    } catch (_) {
      return Colors.blue;
    }
  }

  IconData _parseIcon(String? iconCode) {
    if (iconCode == null) return Icons.category;
    try {
      return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _parseColor(category.colorHex);
    final categoryIcon = _parseIcon(category.icon);
    final isExpense = category.type.toLowerCase() == 'expense';

    return Card(
      elevation: 0,
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
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline,
                        color: colorScheme.error, size: 18),
                    tooltip: 'Delete category',
                  ),
                ],
              ),
              const Spacer(),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isExpense
                      ? colorScheme.errorContainer.withValues(alpha: 0.3)
                      : colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isExpense
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.type.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isExpense
                                ? colorScheme.onErrorContainer
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
