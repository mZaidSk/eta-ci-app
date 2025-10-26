import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key, this.category});

  final Category? category;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  final List<String> _categoryTypes = ['expense', 'income'];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.restaurant,
    Icons.local_grocery_store,
    Icons.local_gas_station,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.movie,
    Icons.shopping_bag,
    Icons.work,
    Icons.account_balance,
    Icons.savings,
    Icons.trending_up,
    Icons.card_giftcard,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
      // Parse color from hex if available
      if (widget.category!.colorHex != null) {
        try {
          final colorValue = int.parse('0xFF${widget.category!.colorHex!}');
          _selectedColor = Color(colorValue);
        } catch (e) {
          _selectedColor = Colors.blue;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.category != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                isEditing ? 'Edit Category' : 'New Category',
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
                // Category Name
                Text(
                  'Category Name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLowest,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Category Type
                Text(
                  'Category Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: _categoryTypes.map((type) {
                    final isSelected = _selectedType == type;
                    final isExpense = type == 'expense';

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: isExpense ? 8 : 0, left: isExpense ? 0 : 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 18,
                                color: isSelected
                                    ? colorScheme.onSecondaryContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colorScheme.onSecondaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          selectedColor: isExpense
                              ? colorScheme.errorContainer
                              : colorScheme.primaryContainer,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Color Selection
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _availableColors.map((color) {
                    final isSelected = _selectedColor.value == color.value;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: colorScheme.outline, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Icon Selection
                Text(
                  'Icon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = _selectedIcon == icon;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withValues(alpha: 0.1)
                                : colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? _selectedColor : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      );
                    },
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveCategory,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();

    try {
      if (widget.category != null) {
        // Update existing category
        final updatedCategory = Category(
          id: widget.category!.id,
          name: _nameController.text.trim(),
          type: _selectedType,
          colorHex: _colorToHex(_selectedColor),
          icon: _selectedIcon.codePoint.toString(),
        );
        await provider.update(updatedCategory);
      } else {
        // Create new category
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          type: _selectedType,
          colorHex: _colorToHex(_selectedColor),
          icon: _selectedIcon.codePoint.toString(),
        );
        await provider.add(newCategory);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category != null
                  ? 'Category updated successfully'
                  : 'Category created successfully'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}