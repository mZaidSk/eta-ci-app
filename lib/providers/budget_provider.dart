import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider() : _service = BudgetService();

  final BudgetService _service;
  bool _loading = false;
  List<Budget> _items = <Budget>[];
  String? _error;

  bool get isLoading => _loading;
  List<Budget> get items => _items;
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      debugPrint('📋 Fetching budgets from API...');
      _items = await _service.getBudgets();
      debugPrint('✅ Fetched ${_items.length} budgets');
    } on DioException catch (e) {
      debugPrint('❌ Error fetching budgets: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to fetch budgets';
    } catch (e) {
      debugPrint('❌ Unexpected error fetching budgets: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(Budget budget) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('➕ Creating budget for category: ${budget.category}');
      final newBudget = await _service.createBudget(
        category: budget.category,
        amount: budget.amount,
        currentExpense: budget.currentExpense,
        startDate: budget.startDate,
        endDate: budget.endDate,
      );

      if (newBudget != null) {
        _items = List<Budget>.from(_items)..add(newBudget);
        debugPrint('✅ Budget created: ${newBudget.id}');
        _error = null;
      } else {
        _error = 'Failed to create budget';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error creating budget: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to create budget';
    } catch (e) {
      debugPrint('❌ Unexpected error creating budget: $e');
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> update(Budget budget) async {
    try {
      _loading = true;
      notifyListeners();

      debugPrint('✏️ Updating budget: ${budget.id}');
      final updatedBudget = await _service.updateBudget(
        id: budget.id,
        category: budget.category,
        amount: budget.amount,
        currentExpense: budget.currentExpense,
        startDate: budget.startDate,
        endDate: budget.endDate,
      );

      if (updatedBudget != null) {
        final idx = _items.indexWhere((b) => b.id == budget.id);
        if (idx != -1) {
          _items = List<Budget>.from(_items)..[idx] = updatedBudget;
          debugPrint('✅ Budget updated: ${updatedBudget.id}');
          _error = null;
        } else {
          _error = 'Budget not found';
        }
      } else {
        _error = 'Failed to update budget';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error updating budget: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to update budget';
    } catch (e) {
      debugPrint('❌ Unexpected error updating budget: $e');
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

      debugPrint('🗑️ Deleting budget: $id');
      final success = await _service.deleteBudget(id);

      if (success) {
        _items = _items.where((b) => b.id != id).toList();
        debugPrint('✅ Budget deleted: $id');
        _error = null;
      } else {
        _error = 'Failed to delete budget';
      }
    } on DioException catch (e) {
      debugPrint('❌ Error deleting budget: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      _error = e.response?.data?['message'] ??
               e.response?.data?['error'] ??
               'Failed to delete budget';
    } catch (e) {
      debugPrint('❌ Unexpected error deleting budget: $e');
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

  // Get budget by ID
  Budget? getById(String id) {
    try {
      return _items.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get budgets by category
  List<Budget> getByCategory(int categoryId) {
    return _items.where((budget) => budget.category == categoryId).toList();
  }

  // Get total budgeted amount
  double get totalBudgetAmount {
    return _items.fold<double>(0.0, (sum, budget) => sum + budget.amount);
  }

  // Get total spent amount
  double get totalSpentAmount {
    return _items.fold<double>(0.0, (sum, budget) => sum + budget.currentExpense);
  }
}
