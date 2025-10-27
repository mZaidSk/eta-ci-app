class RecurringTransaction {
  final String? id;
  final int account;
  final int category;
  final double amount;
  final String? description;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  RecurringTransaction({
    this.id,
    required this.account,
    required this.category,
    required this.amount,
    this.description,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    // Handle id - convert to string if it's a number
    String? id;
    if (json['id'] != null) {
      id = json['id'].toString();
    }

    // Handle amount - parse string or number
    double amount;
    if (json['amount'] is String) {
      amount = double.parse(json['amount']);
    } else {
      amount = (json['amount'] as num).toDouble();
    }

    return RecurringTransaction(
      id: id,
      account: (json['account'] as num).toInt(),
      category: (json['category'] as num).toInt(),
      amount: amount,
      description: json['description'] as String?,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'account': account,
      'category': category,
      'amount': amount.toString(),
      'description': description,
      'frequency': frequency,
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
    };
    return json;
  }

  RecurringTransaction copyWith({
    String? id,
    int? account,
    int? category,
    double? amount,
    String? description,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      account: account ?? this.account,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get frequencyLabel {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return frequency;
    }
  }
}
