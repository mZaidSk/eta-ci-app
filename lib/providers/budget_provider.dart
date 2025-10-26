import 'package:flutter/foundation.dart';
import '../models/budget.dart'; // <-- IMPORT YOUR NEW MODEL

// (DELETE THE OLD BudgetItem CLASS DEFINITION)

class BudgetProvider extends ChangeNotifier {
  BudgetProvider();

  bool _loading = false;
  List<Budget> _items = <Budget>[]; // <-- USE 'Budget'
  String? _error;

  bool get isLoading => _loading;
  List<Budget> get items => _items; // <-- USE 'Budget'
  String? get error => _error;

  Future<void> fetch({Map<String, dynamic>? query}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Mock budgets using the new 'Budget' model
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      _items = [
        Budget(
          id: 'b1',
          amount: 300,
          categoryId: '1', // Assuming ID '1' is 'Food'
          currentExpense: 150.25,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        ),
        Budget(
          id: 'b2',
          amount: 120,
          categoryId: '2', // Assuming ID '2' is 'Transport'
          currentExpense: 45.0,
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // TODO: Add your create, update, delete methods here
}
