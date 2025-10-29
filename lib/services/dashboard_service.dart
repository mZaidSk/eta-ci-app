import 'base_service.dart';

class DashboardService extends BaseService {
  DashboardService() : super();

  // Basic Analytics

  /// Get dashboard summary with total income, expenses, net balance, and accounts
  Future<Map<String, dynamic>> getSummary({int? accountId}) async {
    final response = await client.get(
      '/dashboard/summary/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Get income and expense breakdown by category
  Future<Map<String, dynamic>> getCategoryBreakdown({int? accountId}) async {
    final response = await client.get(
      '/dashboard/category-breakdown/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Compare budgeted amounts vs actual spending per category
  Future<Map<String, dynamic>> getBudgetVsActual({int? accountId}) async {
    final response = await client.get(
      '/dashboard/budget-vs-actual/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Get month-by-month income and expense trends
  Future<Map<String, dynamic>> getMonthlyTrend({int? accountId}) async {
    final response = await client.get(
      '/dashboard/monthly-trend/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  // Advanced Analytics

  /// Calculate comprehensive financial health score (0-100)
  Future<Map<String, dynamic>> getFinancialHealth() async {
    final response = await client.get('/dashboard/financial-health/');
    return response.data;
  }

  /// Get month-over-month and year-over-year spending growth rates
  Future<Map<String, dynamic>> getSpendingTrends({int? accountId}) async {
    final response = await client.get(
      '/dashboard/spending-trends/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Predict future cash flow based on historical averages
  Future<Map<String, dynamic>> getCashFlowForecast({int months = 3}) async {
    final response = await client.get(
      '/dashboard/cash-flow-forecast/',
      queryParameters: {'months': months},
    );
    return response.data;
  }

  /// Analyze how fast budgets are being consumed
  Future<Map<String, dynamic>> getBudgetBurnRate() async {
    final response = await client.get('/dashboard/budget-burn-rate/');
    return response.data;
  }

  /// Analyze spending patterns by day of week and weekly trends
  Future<Map<String, dynamic>> getSpendingPatterns({int? accountId}) async {
    final response = await client.get(
      '/dashboard/spending-patterns/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Detailed category-wise spending analysis with statistics
  Future<Map<String, dynamic>> getCategoryIntelligence({int? accountId}) async {
    final response = await client.get(
      '/dashboard/category-intelligence/',
      queryParameters: accountId != null ? {'account': accountId} : null,
    );
    return response.data;
  }

  /// Statistical analysis with outlier detection
  Future<Map<String, dynamic>> getTransactionStatistics({
    int? accountId,
    int days = 30,
  }) async {
    final response = await client.get(
      '/dashboard/transaction-statistics/',
      queryParameters: {
        if (accountId != null) 'account': accountId,
        'days': days,
      },
    );
    return response.data;
  }

  /// Compare spending/income between two custom date periods
  Future<Map<String, dynamic>> getPeriodComparison({
    required String period1Start,
    required String period1End,
    required String period2Start,
    required String period2End,
    int? accountId,
  }) async {
    final response = await client.get(
      '/dashboard/period-comparison/',
      queryParameters: {
        'period1_start': period1Start,
        'period1_end': period1End,
        'period2_start': period2Start,
        'period2_end': period2End,
        if (accountId != null) 'account': accountId,
      },
    );
    return response.data;
  }
}

