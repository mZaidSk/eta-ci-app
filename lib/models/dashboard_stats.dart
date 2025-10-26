class DashboardStatsModel {
  DashboardStatsModel({required this.totalSpent, required this.totalIncome});
  final double totalSpent;
  final double totalIncome;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => DashboardStatsModel(
        totalSpent: (json['totalSpent'] as num).toDouble(),
        totalIncome: (json['totalIncome'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'totalSpent': totalSpent,
        'totalIncome': totalIncome,
      };
}

