class Budget {
  final String id;
  final String? userId;
  final int category;
  final double amount;
  final double currentExpense;
  final DateTime startDate;
  final DateTime endDate;
  final double? remaining;
  final DateTime? createdAt;

  Budget({
    required this.id,
    this.userId,
    required this.category,
    required this.amount,
    this.currentExpense = 0.0,
    required this.startDate,
    required this.endDate,
    this.remaining,
    this.createdAt,
  });

  // Factory constructor for creating a new Budget instance from a map (e.g., JSON from an API)
  factory Budget.fromJson(Map<String, dynamic> json) {
    // Parse amount - handle both string and number formats
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Budget(
      id: json['id'].toString(),
      userId: json['user']?.toString(),
      category: json['category'] is int ? json['category'] : int.tryParse(json['category'].toString()) ?? 0,
      amount: parseAmount(json['amount']),
      currentExpense: parseAmount(json['current_expense'] ?? json['currentExpense'] ?? '0.0'),
      startDate: DateTime.parse(json['start_date'] ?? json['startDate']),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate']),
      remaining: json['remaining'] != null ? parseAmount(json['remaining']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Method to convert a Budget instance into a map (e.g., for sending to an API)
  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'current_expense': currentExpense,
        'start_date': startDate.toIso8601String().split('T')[0], // Send as date only
        'end_date': endDate.toIso8601String().split('T')[0],
      };

  Budget copyWith({
    String? id,
    String? userId,
    int? category,
    double? amount,
    double? currentExpense,
    DateTime? startDate,
    DateTime? endDate,
    double? remaining,
    DateTime? createdAt,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currentExpense: currentExpense ?? this.currentExpense,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      remaining: remaining ?? this.remaining,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper to get percentage spent
  double get percentageSpent {
    if (amount <= 0) return 0.0;
    return (currentExpense / amount) * 100;
  }

  // Helper to check if budget is exceeded
  bool get isExceeded => currentExpense > amount;

  // Helper to get remaining amount
  double get remainingAmount => amount - currentExpense;
}
