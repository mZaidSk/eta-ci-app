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

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income', icon: Icon(Icons.arrow_downward)),
            Tab(text: 'Expense', icon: Icon(Icons.arrow_upward)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryForm(null),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoriesTab(
            type: 'income',
            onShowForm: _showCategoryForm,
            onShowDeleteDialog: _showDeleteDialog,
          ),
          _CategoriesTab(
            type: 'expense',
            onShowForm: _showCategoryForm,
            onShowDeleteDialog: _showDeleteDialog,
          ),
        ],
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

/// ------------------ Tab Widgets ------------------

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({
    required this.type,
    required this.onShowForm,
    required this.onShowDeleteDialog,
  });

  final String type;
  final Function(Category?) onShowForm;
  final Function(Category) onShowDeleteDialog;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    // Filter categories by type
    final filteredItems = provider.items
        .where((c) => c.type.toLowerCase() == type.toLowerCase())
        .toList();

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
      return _EmptyView(
        message: 'No ${type.toLowerCase()} categories yet',
        description:
            'Add your first ${type.toLowerCase()} category to get started',
        icon: Icons.category_outlined,
        onAdd: () => onShowForm(null),
      );
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
            onEdit: () => onShowForm(category),
            onDelete: () => onShowDeleteDialog(category),
          );
        },
      ),
    );
  }
}

/// ------------------ Helper Widgets ------------------

class _EmptyView extends StatelessWidget {
  final String message;
  final String description;
  final IconData icon;
  final VoidCallback onAdd;

  const _EmptyView({
    required this.message,
    required this.description,
    required this.icon,
    required this.onAdd,
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
