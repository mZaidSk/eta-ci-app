import 'package:flutter/foundation.dart';

// import '../services/dashboard_service.dart';

class DashboardStats {
  DashboardStats({required this.totalSpent, required this.totalIncome});
  final double totalSpent;
  final double totalIncome;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalSpent: (json['totalSpent'] as num).toDouble(),
        totalIncome: (json['totalIncome'] as num).toDouble(),
      );
}

class DashboardProvider extends ChangeNotifier {
  DashboardProvider();

  // final DashboardService _service;
  bool _loading = false;
  DashboardStats? _stats;
  String? _error;

  bool get isLoading => _loading;
  DashboardStats? get stats => _stats;
  String? get error => _error;

  Future<void> fetchStats() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Mock stats without API
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _stats = DashboardStats(totalSpent: 842.35, totalIncome: 2150.00);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

