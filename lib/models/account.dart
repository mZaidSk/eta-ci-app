class Account {
  Account({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
    this.createdAt,
  });

  final String id;
  final String name;
  final String accountType;
  final double balance;
  final DateTime? createdAt;

  factory Account.fromJson(Map<String, dynamic> json) {
    // Parse balance - handle both string and number formats
    double parseBalance(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Account(
      id: json['id'].toString(),
      name: json['name'] as String,
      accountType: json['account_type'] as String,
      balance: parseBalance(json['balance']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'account_type': accountType,
        'balance': balance,
      };

  Account copyWith({
    String? id,
    String? name,
    String? accountType,
    double? balance,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to get account type display name
  String get accountTypeDisplayName {
    switch (accountType.toLowerCase()) {
      case 'savings':
        return 'Savings Account';
      case 'checking':
        return 'Checking Account';
      case 'credit':
        return 'Credit Card';
      case 'investment':
        return 'Investment Account';
      default:
        return accountType;
    }
  }

  // Helper method to get masked account number
  String get maskedNumber {
    // Safely get last 4 characters of ID, padding if necessary
    String getLast4Digits() {
      if (id.length >= 4) {
        return id.substring(id.length - 4);
      } else {
        return id.padLeft(4, '0');
      }
    }

    final last4 = getLast4Digits();

    // Generate a simple masked number based on account type
    switch (accountType.toLowerCase()) {
      case 'credit':
        return '**** **** **** $last4';
      default:
        return '**** $last4';
    }
  }
}
