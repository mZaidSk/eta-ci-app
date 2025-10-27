import 'crud_service.dart';
import '../models/budget.dart';

class BudgetService extends CrudService<Budget> {
  BudgetService() : super(endpoint: '/budgets/');

  /// Get all budgets
  Future<List<Budget>> getBudgets() async {
    final response = await list();
    if (response.data != null && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => Budget.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get a single budget by ID
  Future<Budget?> getBudget(String id) async {
    final response = await getById(id);
    if (response.data != null && response.data['data'] != null) {
      return Budget.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Create a new budget
  Future<Budget?> createBudget({
    required int category,
    required double amount,
    required double currentExpense,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await create({
      'category': category,
      'amount': amount,
      'current_expense': currentExpense,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    });

    if (response.data != null && response.data['data'] != null) {
      return Budget.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Update an existing budget
  Future<Budget?> updateBudget({
    required String id,
    required int category,
    required double amount,
    required double currentExpense,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await update(id, {
      'category': category,
      'amount': amount,
      'current_expense': currentExpense,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
    });

    if (response.data != null && response.data['data'] != null) {
      return Budget.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Delete a budget
  Future<bool> deleteBudget(String id) async {
    try {
      await delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }
}
