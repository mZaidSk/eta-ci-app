import 'package:flutter/foundation.dart' hide Category;
import 'package:dio/dio.dart';

import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider() : _service = CategoryService();

  final CategoryService _service;
  bool _loading = false;
  List<Category> _items = <Category>[];
  String? _error;

  bool get isLoading => _loading;
  List<Category> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      debugPrint('📋 Fetching categories from API...');
      _items = await _service.getCategories();
      debugPrint('✅ Fetched ${_items.length} categories');
    } on DioException catch (e) {
      debugPrint('❌ Error fetching categories: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to fetch categories';
    } catch (e) {
      debugPrint('❌ Unexpected error fetching categories: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Category category) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('➕ Creating category: ${category.name}');
      final newCategory = await _service.createCategory(
        name: category.name,
        type: category.type,
      );

      if (newCategory != null) {
        _items = List<Category>.from(_items)..add(newCategory);
        debugPrint('✅ Category created: ${newCategory.id}');
        _error = null;
      } else {
        _error = 'Failed to create category';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating category: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to create category';
    } catch (e) {
      debugPrint('❌ Unexpected error creating category: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Category category) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('✏️ Updating category: ${category.id}');
      final updatedCategory = await _service.updateCategory(
        id: category.id,
        name: category.name,
        type: category.type,
      );

      if (updatedCategory != null) {
        final idx = _items.indexWhere((c) => c.id == category.id);
        if (idx != -1) {
          _items = List<Category>.from(_items)..[idx] = updatedCategory;
          debugPrint('✅ Category updated: ${updatedCategory.id}');
          _error = null;
        } else {
          _error = 'Category not found';
        }
      } else {
        _error = 'Failed to update category';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating category: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to update category';
    } catch (e) {
      debugPrint('❌ Unexpected error updating category: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('🗑️ Deleting category: $id');
      final success = await _service.deleteCategory(id);

      if (success) {
        _items = _items.where((c) => c.id != id).toList();
        debugPrint('✅ Category deleted: $id');
        _error = null;
      } else {
        _error = 'Failed to delete category';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error deleting category: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to delete category';
    } catch (e) {
      debugPrint('❌ Unexpected error deleting category: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get category by ID
  Category? getById(String id) {
    try {
      return _items.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories by type (income/expense)
  List<Category> getByType(String type) {
    return _items.where((category) => category.type == type).toList();
  }

  // Get expense categories
  List<Category> get expenseCategories => getByType('expense');

  // Get income categories
  List<Category> get incomeCategories => getByType('income');
}

