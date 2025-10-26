// in models/budget.dart

class Budget {
  final String id;
  final String categoryId;
  final double amount;
  final double currentExpense;
  final DateTime startDate;
  final DateTime endDate;

  Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.currentExpense = 0.0, // Default to 0 if not provided
    required this.startDate,
    required this.endDate,
  });

  // Factory constructor for creating a new Budget instance from a map (e.g., JSON from an API)
  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        amount: (json['amount'] as num).toDouble(),
        currentExpense: (json['currentExpense'] as num?)?.toDouble() ?? 0.0,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
      );

  // Method to convert a Budget instance into a map (e.g., for sending to an API)
  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'amount': amount,
        'currentExpense': currentExpense,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
}
