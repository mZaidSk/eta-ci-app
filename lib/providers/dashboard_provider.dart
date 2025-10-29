import 'package:flutter/foundation.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();

  bool _loading = false;
  String? _error;

  // Basic Analytics Data
  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _categoryBreakdown;
  Map<String, dynamic>? _budgetVsActual;
  Map<String, dynamic>? _monthlyTrend;

  // Advanced Analytics Data
  Map<String, dynamic>? _financialHealth;
  Map<String, dynamic>? _spendingTrends;
  Map<String, dynamic>? _cashFlowForecast;
  Map<String, dynamic>? _budgetBurnRate;
  Map<String, dynamic>? _spendingPatterns;
  Map<String, dynamic>? _categoryIntelligence;
  Map<String, dynamic>? _transactionStatistics;

  // Getters
  bool get isLoading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get summary => _summary;
  Map<String, dynamic>? get categoryBreakdown => _categoryBreakdown;
  Map<String, dynamic>? get budgetVsActual => _budgetVsActual;
  Map<String, dynamic>? get monthlyTrend => _monthlyTrend;
  Map<String, dynamic>? get financialHealth => _financialHealth;
  Map<String, dynamic>? get spendingTrends => _spendingTrends;
  Map<String, dynamic>? get cashFlowForecast => _cashFlowForecast;
  Map<String, dynamic>? get budgetBurnRate => _budgetBurnRate;
  Map<String, dynamic>? get spendingPatterns => _spendingPatterns;
  Map<String, dynamic>? get categoryIntelligence => _categoryIntelligence;
  Map<String, dynamic>? get transactionStatistics => _transactionStatistics;

  // Backward compatibility
  DashboardStats? get stats {
    if (_summary == null) return null;
    final data = _summary!['data'];
    return DashboardStats(
      totalSpent: (data['total_expense'] ?? 0).toDouble(),
      totalIncome: (data['total_income'] ?? 0).toDouble(),
    );
  }

  /// Fetch all dashboard data at once (for initial load)
  Future<void> fetchAllDashboardData({int? accountId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all data in parallel for better performance
      await Future.wait([
        fetchSummary(accountId: accountId),
        fetchFinancialHealth(),
        fetchCategoryBreakdown(accountId: accountId),
        fetchBudgetVsActual(accountId: accountId),
        fetchMonthlyTrend(accountId: accountId),
      ]);
    } catch (e) {
      _error = 'Failed to load dashboard: ${e.toString()}';
      print('Error fetching all dashboard data: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetch dashboard summary
  Future<void> fetchSummary({int? accountId}) async {
    try {
      final response = await _service.getSummary(accountId: accountId);
      if (response['success'] == true) {
        _summary = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching summary: $e');
      rethrow;
    }
  }

  /// Fetch category breakdown
  Future<void> fetchCategoryBreakdown({int? accountId}) async {
    try {
      final response = await _service.getCategoryBreakdown(accountId: accountId);
      if (response['success'] == true) {
        _categoryBreakdown = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching category breakdown: $e');
      rethrow;
    }
  }

  /// Fetch budget vs actual
  Future<void> fetchBudgetVsActual({int? accountId}) async {
    try {
      final response = await _service.getBudgetVsActual(accountId: accountId);
      if (response['success'] == true) {
        _budgetVsActual = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching budget vs actual: $e');
      rethrow;
    }
  }

  /// Fetch monthly trend
  Future<void> fetchMonthlyTrend({int? accountId}) async {
    try {
      final response = await _service.getMonthlyTrend(accountId: accountId);
      if (response['success'] == true) {
        _monthlyTrend = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching monthly trend: $e');
      rethrow;
    }
  }

  /// Fetch financial health score
  Future<void> fetchFinancialHealth() async {
    try {
      final response = await _service.getFinancialHealth();
      if (response['success'] == true) {
        _financialHealth = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching financial health: $e');
      rethrow;
    }
  }

  /// Fetch spending trends
  Future<void> fetchSpendingTrends({int? accountId}) async {
    try {
      final response = await _service.getSpendingTrends(accountId: accountId);
      if (response['success'] == true) {
        _spendingTrends = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching spending trends: $e');
    }
  }

  /// Fetch cash flow forecast
  Future<void> fetchCashFlowForecast({int months = 3}) async {
    try {
      final response = await _service.getCashFlowForecast(months: months);
      if (response['success'] == true) {
        _cashFlowForecast = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching cash flow forecast: $e');
    }
  }

  /// Fetch budget burn rate
  Future<void> fetchBudgetBurnRate() async {
    try {
      final response = await _service.getBudgetBurnRate();
      if (response['success'] == true) {
        _budgetBurnRate = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching budget burn rate: $e');
    }
  }

  /// Fetch spending patterns
  Future<void> fetchSpendingPatterns({int? accountId}) async {
    try {
      final response = await _service.getSpendingPatterns(accountId: accountId);
      if (response['success'] == true) {
        _spendingPatterns = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching spending patterns: $e');
    }
  }

  /// Fetch category intelligence
  Future<void> fetchCategoryIntelligence({int? accountId}) async {
    try {
      final response = await _service.getCategoryIntelligence(accountId: accountId);
      if (response['success'] == true) {
        _categoryIntelligence = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching category intelligence: $e');
    }
  }

  /// Fetch transaction statistics
  Future<void> fetchTransactionStatistics({int? accountId, int days = 30}) async {
    try {
      final response = await _service.getTransactionStatistics(
        accountId: accountId,
        days: days,
      );
      if (response['success'] == true) {
        _transactionStatistics = response;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching transaction statistics: $e');
    }
  }

  /// Backward compatibility - fetch basic stats
  Future<void> fetchStats() async {
    await fetchAllDashboardData();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Backward compatibility model
class DashboardStats {
  final double totalSpent;
  final double totalIncome;

  DashboardStats({
    required this.totalSpent,
    required this.totalIncome,
  });

  double get netBalance => totalIncome - totalSpent;
}
